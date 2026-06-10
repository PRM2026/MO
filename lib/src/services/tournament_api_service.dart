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

    if (response.statusCode != 200) {
      throw TournamentApiException(
        'API lỗi ${response.statusCode}: ${response.reasonPhrase}',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final apiResponse = ApiResponse<List<TournamentListItem>>.fromJson(
      body,
      (data) => (data as List<dynamic>)
          .map(
            (item) =>
                TournamentListItem.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );

    if (!apiResponse.success) {
      throw TournamentApiException(
        apiResponse.message.isEmpty
            ? 'Không thể tải giải đấu'
            : apiResponse.message,
      );
    }

    return apiResponse.data ?? [];
  }
}
