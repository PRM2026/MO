import 'package:http/http.dart' as http;

import '../models/referee_dashboard_response.dart';
import '../models/referee_race_participant_response.dart';
import '../models/referee_race_response.dart';
import '../models/referee_race_result_response.dart';
import 'api_client.dart';
import 'auth_storage.dart';

class RefereeDashboardService {
  RefereeDashboardService({
    http.Client? client,
    String? baseUrl,
    AuthStorage? storage,
    ApiClient? apiClient,
  }) : _apiClient =
           apiClient ??
           ApiClient(client: client, baseUrl: baseUrl, storage: storage);

  final ApiClient _apiClient;

  Future<RefereeDashboardResponse> getDashboard() {
    return _apiClient.getObject(
      '/referee/dashboard',
      RefereeDashboardResponse.fromJson,
    );
  }

  Future<List<RefereeRaceResponse>> getAssignedRaces() {
    return _apiClient.getList(
      '/referee/races',
      RefereeRaceResponse.fromJson,
    );
  }

  Future<List<RefereeRaceParticipantResponse>> getRaceParticipants(int raceId) {
    return _apiClient.getList(
      '/referee/races/$raceId/participants',
      RefereeRaceParticipantResponse.fromJson,
    );
  }

  Future<List<RefereeRaceResultResponse>> getRaceResults(int raceId) {
    return _apiClient.getList(
      '/races/$raceId/results',
      RefereeRaceResultResponse.fromJson,
      authenticated: false,
    );
  }

  Future<List<RefereeRaceResultResponse>> finalizeRaceResults(
    int raceId,
    List<Map<String, dynamic>> results,
  ) {
    return _apiClient.postList(
      '/referee/races/$raceId/results/finalize',
      {'results': results},
      RefereeRaceResultResponse.fromJson,
    );
  }
}
