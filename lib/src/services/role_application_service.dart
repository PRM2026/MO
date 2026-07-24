import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/role_request_data.dart';
import '../services/auth_storage.dart';

class RoleApplicationApiException implements Exception {
  RoleApplicationApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class RoleApplicationService {
  RoleApplicationService({
    http.Client? client,
    String? baseUrl,
    AuthStorage? storage,
  }) : _client = client ?? http.Client(),
       _baseUrl = baseUrl ?? ApiConfig.baseUrl,
       _storage = storage ?? AuthStorage();

  final http.Client _client;
  final String _baseUrl;
  final AuthStorage _storage;

  Future<Map<String, dynamic>> getMyApplication() async {
    return _get('/role-applications/me');
  }

  Future<List<Map<String, dynamic>>> getMyApplicationHistory() async {
    final data = await _getList('/role-applications/me/history');
    return data;
  }

  Future<Map<String, dynamic>> submitSpectator(Map<String, String> fields) {
    return _postJson('/role-applications/spectator', fields);
  }

  Future<Map<String, dynamic>> submitOwner(
    Map<String, String> fields,
    File verificationDocument,
  ) {
    return _postMultipart('/role-applications/owner', fields, {
      'verificationDocument': verificationDocument,
    });
  }

  Future<Map<String, dynamic>> submitJockey(
    Map<String, String> fields, {
    File? avatar,
    File? achievements,
    required File licenseDocument,
  }) {
    final files = <String, File>{'licenseDocument': licenseDocument};
    if (avatar != null) files['avatar'] = avatar;
    if (achievements != null) files['achievements'] = achievements;
    return _postMultipart('/role-applications/jockey', fields, files);
  }

  Future<Map<String, dynamic>> submitReferee(
    Map<String, String> fields,
    File certificationDocument,
  ) {
    return _postMultipart('/role-applications/referee', fields, {
      'certificationDocument': certificationDocument,
    });
  }

  Future<Map<String, dynamic>> submitRole(
    SystemRoleType role,
    Map<String, String> textFields,
    Map<String, File> files,
  ) {
    switch (role) {
      case SystemRoleType.spectator:
        return submitSpectator({
          'displayName': textFields['displayName'] ?? '',
          if (textFields['phone']?.isNotEmpty == true)
            'phone': textFields['phone']!,
          if (textFields['location']?.isNotEmpty == true)
            'location': textFields['location']!,
          if (textFields['favoriteHorseBreed']?.isNotEmpty == true)
            'favoriteHorseBreed': textFields['favoriteHorseBreed']!,
          if (textFields['bio']?.isNotEmpty == true) 'bio': textFields['bio']!,
        });
      case SystemRoleType.horseOwner:
        return submitOwner({
          'stableName': textFields['stableName'] ?? '',
          'address': textFields['address'] ?? '',
          if (textFields['experienceYears']?.isNotEmpty == true)
            'experienceYears': textFields['experienceYears']!,
          if (textFields['bio']?.isNotEmpty == true) 'bio': textFields['bio']!,
        }, files['verificationDocument']!);
      case SystemRoleType.jockey:
        return submitJockey(
          {
            'licenseNumber': textFields['licenseNumber'] ?? '',
            if (textFields['experienceYears']?.isNotEmpty == true)
              'experienceYears': textFields['experienceYears']!,
            if (textFields['heightCm']?.isNotEmpty == true)
              'heightCm': textFields['heightCm']!,
            if (textFields['weightKg']?.isNotEmpty == true)
              'weightKg': textFields['weightKg']!,
            if (textFields['bio']?.isNotEmpty == true)
              'bio': textFields['bio']!,
            if (textFields['awards']?.isNotEmpty == true)
              'awards': textFields['awards']!,
            if (textFields['specialties']?.isNotEmpty == true)
              'specialties': textFields['specialties']!,
          },
          licenseDocument: files['licenseDocument']!,
          avatar: files['avatar'],
          achievements: files['achievements'],
        );
      case SystemRoleType.referee:
        return submitReferee({
          'licenseNumber': textFields['licenseNumber'] ?? '',
          if (textFields['experienceYears']?.isNotEmpty == true)
            'experienceYears': textFields['experienceYears']!,
          'specialty': textFields['specialty'] ?? '',
          if (textFields['bio']?.isNotEmpty == true) 'bio': textFields['bio']!,
        }, files['certificationDocument']!);
    }
  }

  Future<Map<String, dynamic>> _get(String path) async {
    final token = await _requireToken();
    final uri = Uri.parse('$_baseUrl$path');
    final response = await _client.get(
      uri,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );
    return _decodeResponse(response);
  }

  Future<List<Map<String, dynamic>>> _getList(String path) async {
    final token = await _requireToken();
    final uri = Uri.parse('$_baseUrl$path');
    final response = await _client.get(
      uri,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    Map<String, dynamic>? decoded;
    try {
      decoded = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw RoleApplicationApiException('Phản hồi từ máy chủ không hợp lệ.');
    }

    final apiResponse = ApiResponse<List<dynamic>>.fromJson(
      decoded,
      (data) => data as List<dynamic>,
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        apiResponse.success) {
      return (apiResponse.data ?? const [])
          .whereType<Map<String, dynamic>>()
          .toList();
    }

    throw RoleApplicationApiException(
      _resolveErrorMessage(decoded, apiResponse.message),
    );
  }

  Future<Map<String, dynamic>> _postJson(
    String path,
    Map<String, String> body,
  ) async {
    final token = await _requireToken();
    final uri = Uri.parse('$_baseUrl$path');
    final response = await _client.post(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> _postMultipart(
    String path,
    Map<String, String> fields,
    Map<String, File> files,
  ) async {
    final token = await _requireToken();
    final uri = Uri.parse('$_baseUrl$path');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Accept'] = 'application/json';
    request.headers['Authorization'] = 'Bearer $token';

    fields.forEach((key, value) {
      if (value.isNotEmpty) request.fields[key] = value;
    });

    for (final entry in files.entries) {
      request.files.add(
        await http.MultipartFile.fromPath(entry.key, entry.value.path),
      );
    }

    final streamed = await _client.send(request);
    final response = await http.Response.fromStream(streamed);
    return _decodeResponse(response);
  }

  Future<String> _requireToken() async {
    final token = await _storage.getToken();
    if (token == null || token.isEmpty) {
      throw RoleApplicationApiException(
        'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
      );
    }
    return token;
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    Map<String, dynamic>? decoded;
    try {
      decoded = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw RoleApplicationApiException('Phản hồi từ máy chủ không hợp lệ.');
    }

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      decoded,
      (data) => data as Map<String, dynamic>,
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        apiResponse.success) {
      return apiResponse.data ?? {};
    }

    throw RoleApplicationApiException(
      _resolveErrorMessage(decoded, apiResponse.message),
    );
  }

  String _resolveErrorMessage(
    Map<String, dynamic> decoded,
    String fallbackMessage,
  ) {
    final message = fallbackMessage.trim();
    if (message.isNotEmpty && message != 'Validation failed') {
      return _translateMessage(message);
    }

    final data = decoded['data'];
    if (data is Map<String, dynamic> && data.isNotEmpty) {
      final firstError = data.values.first;
      if (firstError is String && firstError.isNotEmpty) {
        return _translateMessage(firstError);
      }
    }

    return 'Gửi hồ sơ thất bại. Vui lòng thử lại.';
  }

  String _translateMessage(String message) {
    const translations = {
      'Role already approved': 'Tài khoản đã có vai trò được duyệt.',
      'A role application is already pending':
          'Bạn đang có yêu cầu vai trò chờ duyệt.',
      'Stable name is required': 'Vui lòng nhập tên trang trại / chuồng ngựa.',
      'Address is required': 'Vui lòng nhập địa chỉ trang trại.',
      'Display name is required': 'Vui lòng nhập họ và tên hiển thị.',
      'License number is required': 'Vui lòng nhập số giấy phép.',
      'Specialty is required': 'Vui lòng nhập chuyên môn.',
      'License number already exists': 'Số giấy phép đã tồn tại.',
    };

    for (final entry in translations.entries) {
      if (message.contains(entry.key)) return entry.value;
    }

    return message;
  }
}
