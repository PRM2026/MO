import 'package:http/http.dart' as http;

import '../models/jockey_race_response.dart';
import '../models/jockey_race_result_response.dart';
import 'api_client.dart';
import 'api_exception.dart';
import 'auth_storage.dart';

class JockeyRaceApiException extends ApiException {
  const JockeyRaceApiException(super.message, {super.statusCode, super.code});
}

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

  Future<List<JockeyRaceResponse>> getJockeyRaces() {
    return _run(
      () => _apiClient.getList('/jockey/races', JockeyRaceResponse.fromJson),
    );
  }

  Future<List<JockeyRaceResultResponse>> getRaceResults(String raceId) {
    return _run(
      () => _apiClient.getList(
        '/races/$raceId/results',
        JockeyRaceResultResponse.fromJson,
        authenticated: false,
      ),
    );
  }

  Future<List<JockeyChallengeStandingResponse>> getJockeyChallengeStandings(
    String tournamentId,
  ) {
    return _run(
      () => _apiClient.getList(
        '/tournaments/$tournamentId/jockey-challenge',
        JockeyChallengeStandingResponse.fromJson,
        authenticated: false,
      ),
    );
  }

  Future<T> _run<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on ApiException catch (error) {
      throw JockeyRaceApiException(
        error.message,
        statusCode: error.statusCode,
        code: error.code,
      );
    }
  }
}
