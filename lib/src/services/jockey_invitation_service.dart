import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/jockey_invitation_response.dart';
import 'auth_storage.dart';

class JockeyInvitationApiException implements Exception {
  JockeyInvitationApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class JockeyInvitationService {
  JockeyInvitationService({
    http.Client? client,
    String? baseUrl,
    AuthStorage? storage,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? ApiConfig.baseUrl,
        _storage = storage ?? AuthStorage();

  final http.Client _client;
  final String _baseUrl;
  final AuthStorage _storage;

  Future<List<JockeyInvitationResponse>> getJockeyInvitations() async {
    final list = await _getList('/jockey/invitations');
    return list.map(JockeyInvitationResponse.fromJson).toList();
  }

  Future<JockeyInvitationResponse> getJockeyInvitation(int id) async {
    final data = await _get('/jockey/invitations/$id');
    return JockeyInvitationResponse.fromJson(data);
  }

  Future<JockeyInvitationResponse> acceptInvitation(
    int id, {
    String? note,
  }) async {
    final data = await _putJson(
      '/jockey/invitations/$id/accept',
      note != null && note.trim().isNotEmpty ? {'note': note.trim()} : {},
    );
    return JockeyInvitationResponse.fromJson(data);
  }

  Future<JockeyInvitationResponse> rejectInvitation(
    int id, {
    String? note,
  }) async {
    final data = await _putJson(
      '/jockey/invitations/$id/reject',
      note != null && note.trim().isNotEmpty ? {'note': note.trim()} : {},
    );
    return JockeyInvitationResponse.fromJson(data);
  }

  Future<List<Map<String, dynamic>>> _getList(String path) async {
    final token = await _requireToken();
    final uri = Uri.parse('$_baseUrl$path');
    final response = await _client.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    Map<String, dynamic>? decoded;
    try {
      decoded = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw JockeyInvitationApiException('Phản hồi từ máy chủ không hợp lệ.');
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

    throw JockeyInvitationApiException(
      _resolveErrorMessage(decoded, apiResponse.message),
    );
  }

  Future<Map<String, dynamic>> _get(String path) async {
    final token = await _requireToken();
    final uri = Uri.parse('$_baseUrl$path');
    final response = await _client.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return _decodeObject(response);
  }

  Future<Map<String, dynamic>> _putJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    final token = await _requireToken();
    final uri = Uri.parse('$_baseUrl$path');
    final response = await _client.put(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
    return _decodeObject(response);
  }

  Map<String, dynamic> _decodeObject(http.Response response) {
    Map<String, dynamic>? decoded;
    try {
      decoded = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw JockeyInvitationApiException('Phản hồi từ máy chủ không hợp lệ.');
    }

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      decoded,
      (data) => data as Map<String, dynamic>,
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        apiResponse.success &&
        apiResponse.data != null) {
      return apiResponse.data!;
    }

    throw JockeyInvitationApiException(
      _resolveErrorMessage(decoded, apiResponse.message),
    );
  }

  Future<String> _requireToken() async {
    final token = await _storage.getToken();
    if (token == null || token.isEmpty) {
      throw JockeyInvitationApiException(
        'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
      );
    }
    return token;
  }

  String _resolveErrorMessage(
    Map<String, dynamic> decoded,
    String fallbackMessage,
  ) {
    final message = fallbackMessage.trim();
    if (message.isNotEmpty && message != 'Validation failed') {
      return message;
    }

    final data = decoded['data'];
    if (data is Map<String, dynamic> && data.isNotEmpty) {
      final firstError = data.values.first;
      if (firstError is String && firstError.isNotEmpty) {
        return firstError;
      }
    }

    return 'Không thể xử lý lời mời thi đấu. Vui lòng thử lại.';
  }
}
