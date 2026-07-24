import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/owner_tournament_detail.dart';
import '../models/tournament_list_item.dart';

class TournamentApiException implements Exception {
  TournamentApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class TournamentApiService {
  TournamentApiService({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? ApiConfig.baseUrl;

  final http.Client _client;
  final String _baseUrl;

  Future<List<TournamentListItem>> fetchTournaments() async {
    final uri = Uri.parse('$_baseUrl/tournaments');
    final response = await _client.get(
      uri,
      headers: const {'Accept': 'application/json'},
    );

    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (_) {
      throw TournamentApiException('Phản hồi từ máy chủ không hợp lệ.');
    }

    final data = body is List
        ? body
        : body is Map<String, dynamic> && body['data'] is List
        ? body['data'] as List
        : const <dynamic>[];
    final success = body is List || body is Map && body['success'] != false;

    if (response.statusCode >= 200 && response.statusCode < 300 && success) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(TournamentListItem.fromJson)
          .toList(growable: false);
    }

    throw TournamentApiException(
      body is Map<String, dynamic> &&
              '${body['message'] ?? ''}'.trim().isNotEmpty
          ? '${body['message']}'
          : 'Không thể tải giải đấu.',
    );
  }

  Future<OwnerTournamentDetail> fetchTournamentDetail(String id) async {
    final uri = Uri.parse('$_baseUrl/tournaments/$id');
    final response = await _client.get(
      uri,
      headers: const {'Accept': 'application/json'},
    );

    final body = _decodeResponse(response);
    final data = body['data'] is Map<String, dynamic>
        ? body['data'] as Map<String, dynamic>
        : body;
    final success = body['success'] != false;

    if (response.statusCode >= 200 && response.statusCode < 300 && success) {
      return OwnerTournamentDetail.fromJson(data);
    }

    throw TournamentApiException(
      '${body['message'] ?? ''}'.trim().isNotEmpty
          ? '${body['message']}'
          : 'Không thể tải chi tiết giải đấu.',
    );
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw TournamentApiException('Phản hồi từ máy chủ không hợp lệ.');
    }
  }
}
