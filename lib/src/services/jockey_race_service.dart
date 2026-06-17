import 'package:http/http.dart' as http;

import 'api_client.dart';
import 'auth_storage.dart';

class JockeyRaceService {
  JockeyRaceService({
    http.Client? client,
    String? baseUrl,
    AuthStorage? storage,
    ApiClient? apiClient,
  }) : _apiClient =
           apiClient ??
           ApiClient(client: client, baseUrl: baseUrl, storage: storage);

  final ApiClient _apiClient;

  Future<List<Map<String, dynamic>>> getJockeyRaces() {
    return _apiClient.getList('/jockey/races', (json) => json);
  }

  Future<List<Map<String, dynamic>>> getRaceResults(String raceId) {
    return _apiClient.getList(
      '/races/$raceId/results',
      (json) => json,
      authenticated: false,
    );
  }

  Future<List<Map<String, dynamic>>> getJockeyChallengeStandings(
    String tournamentId,
  ) {
    return _apiClient.getList(
      '/tournaments/$tournamentId/jockey-challenge',
      (json) => json,
      authenticated: false,
    );
  }
}
