import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/auth_session.dart';

class AuthApiException implements Exception {
  AuthApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthApiService {
  AuthApiService({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? ApiConfig.baseUrl;

  final http.Client _client;
  final String _baseUrl;

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    return _postAuth(
      path: '/auth/login',
      body: {
        'email': email.trim(),
        'password': password,
      },
    );
  }

  Future<AuthSession> register({
    required String username,
    required String fullName,
    required String email,
    required String password,
  }) async {
    return _postAuth(
      path: '/auth/register',
      body: {
        'username': username,
        'fullName': fullName,
        'email': email.trim(),
        'password': password,
      },
    );
  }

  Future<void> changePassword({
    required String token,
    required String currentPassword,
    required String newPassword,
  }) async {
    final uri = Uri.parse('$_baseUrl/auth/password');
    final response = await _client.put(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );

    Map<String, dynamic>? decoded;
    try {
      decoded = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw AuthApiException('Phản hồi từ máy chủ không hợp lệ.');
    }

    final success = decoded['success'] as bool? ?? false;

    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        success) {
      return;
    }

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      decoded,
      (data) => data as Map<String, dynamic>,
    );
    throw AuthApiException(_resolveErrorMessage(apiResponse, decoded));
  }

  Future<AuthSession> _postAuth({
    required String path,
    required Map<String, dynamic> body,
  }) async {
    final uri = Uri.parse('$_baseUrl$path');
    final response = await _client.post(
      uri,
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    Map<String, dynamic>? decoded;
    try {
      decoded = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw AuthApiException('Phản hồi từ máy chủ không hợp lệ.');
    }

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      decoded,
      (data) => data as Map<String, dynamic>,
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        apiResponse.success &&
        apiResponse.data != null) {
      final session = AuthSession.fromJson(apiResponse.data!);
      if (session.token.isEmpty) {
        throw AuthApiException('Không nhận được token đăng nhập.');
      }
      if (session.twoFactorRequired) {
        throw AuthApiException(
          'Tài khoản yêu cầu xác minh 2 bước. Vui lòng đăng nhập trên web.',
        );
      }
      return session;
    }

    throw AuthApiException(_resolveErrorMessage(apiResponse, decoded));
  }

  String _resolveErrorMessage(
    ApiResponse<Map<String, dynamic>> apiResponse,
    Map<String, dynamic> decoded,
  ) {
    final message = apiResponse.message.trim();
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

    return 'Yêu cầu thất bại. Vui lòng thử lại.';
  }

  String _translateMessage(String message) {
    const translations = {
      'Invalid email or password': 'Email hoặc mật khẩu không đúng.',
      'Registered successfully': 'Đăng ký thành công.',
      'Login successful': 'Đăng nhập thành công.',
      'Password updated': 'Mật khẩu đã được cập nhật.',
      'Current password is required': 'Vui lòng nhập mật khẩu hiện tại.',
      'New password is required': 'Vui lòng nhập mật khẩu mới.',
    };

    for (final entry in translations.entries) {
      if (message.contains(entry.key)) return entry.value;
    }

    if (message.contains('Email already in use')) {
      return 'Email đã được sử dụng.';
    }
    if (message.contains('Username already taken')) {
      return 'Tên đăng nhập đã tồn tại.';
    }
    if (message.contains('Current password is incorrect') ||
        message.contains('Invalid current password')) {
      return 'Mật khẩu hiện tại không đúng.';
    }
    if (message.contains('New password must be different')) {
      return 'Mật khẩu mới phải khác mật khẩu hiện tại.';
    }

    return message;
  }
}
