import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/referee_dashboard_response.dart';
import '../models/referee_race_participant_response.dart';
import '../models/referee_race_response.dart';
import '../models/referee_race_result_response.dart';
import '../models/referee_violation_response.dart';
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
    return _apiClient.getList('/referee/races', RefereeRaceResponse.fromJson);
  }

  Future<List<RefereeRaceResponse>>
  getAssignedRacesWithParticipantCounts() async {
    final races = await getAssignedRaces();
    return Future.wait(
      races.map((race) async {
        final raceId = race.id;
        if (raceId == null) return race;
        try {
          final participants = await getRaceParticipants(raceId);
          return race.copyWithParticipantCount(participants.length);
        } catch (_) {
          return race;
        }
      }),
    );
  }

  Future<int> getPendingCheckInCount() {
    return _apiClient.getObject(
      '/referee/dashboard/pending-check-in-count',
      (json) => _readInt(json['count']),
    );
  }

  Future<int> getViolationCount() async {
    final violations = await getViolations();
    return violations.length;
  }

  Future<List<RefereeViolationResponse>> getViolations() async {
    final violations = await _apiClient.getList(
      '/referee/violations',
      RefereeViolationResponse.fromJson,
    );
    if (kDebugMode) {
      debugPrint('GET /referee/violations: ${violations.length} violation(s)');
    }
    return violations;
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

int _readInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}
