import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/api_response.dart';
import 'api_exception.dart';
import 'auth_storage.dart';

class ApiClient {
  ApiClient({http.Client? client, String? baseUrl, AuthStorage? storage})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? ApiConfig.baseUrl,
      _storage = storage ?? AuthStorage();

  final http.Client _client;
  final String _baseUrl;
  final AuthStorage _storage;

  Future<T> getObject<T>(
    String path,
    T Function(Map<String, dynamic>) mapper, {
    bool authenticated = true,
    bool allowBareResponse = false,
  }) async {
    final response = await _send('GET', path, authenticated: authenticated);
    return _decodeObject(
      response,
      mapper,
      allowBareResponse: allowBareResponse,
    );
  }

  Future<List<T>> getList<T>(
    String path,
    T Function(Map<String, dynamic>) mapper, {
    bool authenticated = true,
    bool allowBareResponse = false,
  }) async {
    final response = await _send('GET', path, authenticated: authenticated);
    return _decodeList(response, mapper, allowBareResponse: allowBareResponse);
  }

  Future<ApiPage<T>> getPage<T>(
    String path,
    T Function(Map<String, dynamic>) mapper, {
    bool authenticated = true,
  }) async {
    final response = await _send('GET', path, authenticated: authenticated);
    return _decodePage(response, mapper);
  }

  Future<T> postObject<T>(
    String path,
    Map<String, dynamic> body,
    T Function(Map<String, dynamic>) mapper,
  ) async {
    final response = await _send('POST', path, body: body);
    return _decodeObject(response, mapper);
  }

  Future<List<T>> postList<T>(
    String path,
    Map<String, dynamic> body,
    T Function(Map<String, dynamic>) mapper,
  ) async {
    final response = await _send('POST', path, body: body);
    return _decodeList(response, mapper);
  }

  Future<T> putObject<T>(
    String path,
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>) mapper,
  ) async {
    final response = await _send('PUT', path, body: body);
    return _decodeObject(response, mapper);
  }

  Future<T?> putOptionalObject<T>(
    String path,
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>) mapper,
  ) async {
    final response = await _send('PUT', path, body: body);
    return _decodeOptionalObject(response, mapper);
  }

  Future<void> delete(String path) async {
    final response = await _send('DELETE', path);
    _decodeVoid(response);
  }

  Future<T> multipartObject<T>(
    String method,
    String path,
    Map<String, String> fields,
    Map<String, String> filePaths,
    T Function(Map<String, dynamic>) mapper,
  ) async {
    final request = http.MultipartRequest(method, _uri(path));
    request.headers.addAll(await _headers(authenticated: true));
    request.fields.addAll(fields);

    for (final entry in filePaths.entries) {
      if (entry.value.isEmpty) continue;
      request.files.add(
        await http.MultipartFile.fromPath(entry.key, entry.value),
      );
    }

    final streamed = await _client.send(request);
    final response = await http.Response.fromStream(streamed);
    return _decodeObject(response, mapper);
  }

  Future<T?> multipartOptionalObject<T>(
    String method,
    String path,
    Map<String, String> fields,
    Map<String, String> filePaths,
    T Function(Map<String, dynamic>) mapper, {
    Map<String, ({List<int> bytes, String filename})> memoryFiles = const {},
  }) async {
    final request = http.MultipartRequest(method, _uri(path));
    request.headers.addAll(await _headers(authenticated: true));
    request.fields.addAll(fields);

    for (final entry in filePaths.entries) {
      if (entry.value.isEmpty) continue;
      request.files.add(
        await http.MultipartFile.fromPath(entry.key, entry.value),
      );
    }
    for (final entry in memoryFiles.entries) {
      request.files.add(
        http.MultipartFile.fromBytes(
          entry.key,
          entry.value.bytes,
          filename: entry.value.filename,
        ),
      );
    }

    final streamed = await _client.send(request);
    final response = await http.Response.fromStream(streamed);
    return _decodeOptionalMultipartObject(response, mapper);
  }

  Future<http.Response> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) async {
    final headers = await _headers(authenticated: authenticated);
    final uri = _uri(path);
    final encodedBody = body == null ? null : jsonEncode(body);
    if (encodedBody != null) {
      headers['Content-Type'] = 'application/json';
    }

    return switch (method) {
      'GET' => _client.get(uri, headers: headers),
      'POST' => _client.post(uri, headers: headers, body: encodedBody),
      'PUT' => _client.put(uri, headers: headers, body: encodedBody),
      'DELETE' => _client.delete(uri, headers: headers),
      _ => throw ApiException('Phuong thuc API khong duoc ho tro: $method.'),
    };
  }

  Future<Map<String, String>> _headers({required bool authenticated}) async {
    final headers = <String, String>{'Accept': 'application/json'};

    if (authenticated) {
      final token = await _storage.getToken();
      if (token == null || token.isEmpty) {
        throw const ApiException(
          'Phien dang nhap da het han. Vui long dang nhap lai.',
        );
      }
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Uri _uri(String path) {
    final normalizedBase = _baseUrl.endsWith('/')
        ? _baseUrl.substring(0, _baseUrl.length - 1)
        : _baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$normalizedBase$normalizedPath');
  }

  T _decodeObject<T>(
    http.Response response,
    T Function(Map<String, dynamic>) mapper, {
    bool allowBareResponse = false,
  }) {
    final apiResponse = _decodeApiResponse<Map<String, dynamic>>(response, (
      data,
    ) {
      if (data is Map<String, dynamic>) return data;
      throw const ApiException('Phan hoi tu may chu khong hop le.');
    }, allowBareResponse: allowBareResponse);
    final data = apiResponse.data;
    if (data == null) {
      throw ApiException(
        apiResponse.message.isNotEmpty
            ? apiResponse.message
            : 'Phan hoi tu may chu khong co du lieu.',
        statusCode: response.statusCode,
      );
    }
    return mapper(data);
  }

  List<T> _decodeList<T>(
    http.Response response,
    T Function(Map<String, dynamic>) mapper, {
    bool allowBareResponse = false,
  }) {
    final apiResponse = _decodeApiResponse<List<dynamic>>(response, (data) {
      if (data is List<dynamic>) return data;
      throw const ApiException('Phan hoi tu may chu khong hop le.');
    }, allowBareResponse: allowBareResponse);

    return (apiResponse.data ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(mapper)
        .toList(growable: false);
  }

  T? _decodeOptionalObject<T>(
    http.Response response,
    T Function(Map<String, dynamic>) mapper,
  ) {
    final apiResponse = _decodeApiResponse<Object?>(
      response,
      (data) => data,
      allowNullData: true,
    );
    final data = apiResponse.data;
    if (data == null) return null;
    if (data is Map<String, dynamic>) return mapper(data);
    throw ApiException(
      'Phan hoi tu may chu khong hop le.',
      statusCode: response.statusCode,
    );
  }

  T? _decodeOptionalMultipartObject<T>(
    http.Response response,
    T Function(Map<String, dynamic>) mapper,
  ) {
    final isSuccessStatus =
        response.statusCode >= 200 && response.statusCode < 300;
    if (isSuccessStatus && response.body.trim().isEmpty) return null;

    final apiResponse = _decodeApiResponse<Object?>(
      response,
      (data) => data,
      allowNullData: true,
      allowBareResponse: true,
    );
    final data = apiResponse.data;
    if (data == null) return null;
    if (data is Map<String, dynamic>) return mapper(data);
    throw ApiException(
      'Phan hoi tu may chu khong hop le.',
      statusCode: response.statusCode,
    );
  }

  ApiPage<T> _decodePage<T>(
    http.Response response,
    T Function(Map<String, dynamic>) mapper,
  ) {
    final apiResponse = _decodeApiResponse<Map<String, dynamic>>(response, (
      data,
    ) {
      if (data is Map<String, dynamic>) return data;
      throw const ApiException('Phan hoi tu may chu khong hop le.');
    });
    final page = apiResponse.data;
    if (page == null) {
      throw ApiException(
        apiResponse.message.isNotEmpty
            ? apiResponse.message
            : 'Phan hoi tu may chu khong co du lieu.',
        statusCode: response.statusCode,
      );
    }

    return ApiPage<T>.fromJson(page, mapper);
  }

  void _decodeVoid(http.Response response) {
    _decodeApiResponse<Object?>(response, (data) => data, allowNullData: true);
  }

  ApiResponse<T> _decodeApiResponse<T>(
    http.Response response,
    T Function(Object? json) fromJsonT, {
    bool allowNullData = false,
    bool allowBareResponse = false,
  }) {
    final Object? decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      throw ApiException(
        'Phan hoi tu may chu khong hop le.',
        statusCode: response.statusCode,
      );
    }

    final isSuccessStatus =
        response.statusCode >= 200 && response.statusCode < 300;
    if (decoded is! Map<String, dynamic> || !decoded.containsKey('success')) {
      if (!isSuccessStatus) {
        throw ApiException(
          decoded is Map && decoded['message'] is String
              ? decoded['message'] as String
              : 'Khong the thuc hien yeu cau. Vui long thu lai.',
          statusCode: response.statusCode,
        );
      }
      if (!allowBareResponse) {
        throw ApiException(
          'Phan hoi tu may chu khong hop le.',
          statusCode: response.statusCode,
        );
      }
      if (decoded == null && allowNullData) {
        return ApiResponse<T>(success: true, message: '', data: null);
      }
      return ApiResponse<T>(
        success: true,
        message: '',
        data: fromJsonT(decoded),
      );
    }

    final success = decoded['success'] as bool? ?? false;
    final message = decoded['message'] as String? ?? '';
    final rawData = decoded['data'];

    if (!isSuccessStatus || !success) {
      throw ApiException(
        _resolveErrorMessage(message, rawData),
        statusCode: response.statusCode,
        code: _readErrorCode(decoded),
      );
    }

    if (rawData == null && allowNullData) {
      return ApiResponse<T>(success: success, message: message, data: null);
    }

    return ApiResponse<T>(
      success: success,
      message: message,
      data: fromJsonT(rawData),
    );
  }

  String _resolveErrorMessage(String message, Object? data) {
    if (message.isNotEmpty) return message;

    final validationMessage = _firstValidationMessage(data);
    if (validationMessage != null && validationMessage.isNotEmpty) {
      return validationMessage;
    }

    return 'Khong the thuc hien yeu cau. Vui long thu lai.';
  }

  String? _firstValidationMessage(Object? data) {
    if (data is! Map) return null;

    for (final value in data.values) {
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
      if (value is List && value.isNotEmpty) {
        final first = value.first;
        if (first is String && first.trim().isNotEmpty) {
          return first.trim();
        }
      }
    }

    return null;
  }

  String? _readErrorCode(Map<String, dynamic> decoded) {
    final code = decoded['code'];
    return code is String && code.isNotEmpty ? code : null;
  }
}

class ApiPage<T> {
  const ApiPage({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.number,
    required this.size,
  });

  final List<T> content;
  final int totalElements;
  final int totalPages;
  final int number;
  final int size;

  factory ApiPage.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) mapper,
  ) {
    final content = json['content'];
    return ApiPage(
      content: content is List
          ? content.whereType<Map<String, dynamic>>().map(mapper).toList()
          : const [],
      totalElements: _readInt(json['totalElements']),
      totalPages: _readInt(json['totalPages']),
      number: _readInt(json['number']),
      size: _readInt(json['size']),
    );
  }

  static int _readInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
