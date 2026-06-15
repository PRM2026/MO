import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/owner_horse_item.dart';
import 'auth_storage.dart';

class OwnerApiException implements Exception {
  OwnerApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class OwnerHorseService {
  OwnerHorseService({
    http.Client? client,
    String? baseUrl,
    AuthStorage? storage,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? ApiConfig.baseUrl,
        _storage = storage ?? AuthStorage();

  final http.Client _client;
  final String _baseUrl;
  final AuthStorage _storage;

  Future<List<OwnerHorseItem>> getOwnerHorses() async {
    final token = await _requireToken();
    final uri = Uri.parse('$_baseUrl/owner/horses');
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
      throw OwnerApiException('Phản hồi từ máy chủ không hợp lệ.');
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
          .map(OwnerHorseItem.fromJson)
          .toList();
    }

    throw OwnerApiException(
      apiResponse.message.isNotEmpty
          ? apiResponse.message
          : 'Không thể tải danh sách ngựa.',
    );
  }

  Future<String> _requireToken() async {
    final token = await _storage.getToken();
    if (token == null || token.isEmpty) {
      throw OwnerApiException(
        'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
      );
    }
    return token;
  }
}
