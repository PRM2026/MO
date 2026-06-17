import 'package:http/http.dart' as http;

import '../models/referee_dashboard_response.dart';
import '../models/referee_race_response.dart';
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
}
