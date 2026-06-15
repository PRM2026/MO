import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/api_response.dart';
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

    Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw TournamentApiException('Phản hồi từ máy chủ không hợp lệ.');
    }

    final apiResponse = ApiResponse<List<dynamic>>.fromJson(
      body,
      (data) => data as List<dynamic>,
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        apiResponse.success) {
      return (apiResponse.data ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(TournamentListItem.fromJson)
          .toList(growable: false);
    }

    throw TournamentApiException(
      apiResponse.message.isNotEmpty
          ? apiResponse.message
          : 'Không thể tải giải đấu.',
    );
  }
}
