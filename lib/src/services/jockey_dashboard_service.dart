import 'package:http/http.dart' as http;

import '../models/jockey_dashboard_response.dart';
import 'api_client.dart';
import 'auth_storage.dart';

class JockeyDashboardService {
  JockeyDashboardService({
    http.Client? client,
    String? baseUrl,
    AuthStorage? storage,
    ApiClient? apiClient,
  }) : _apiClient =
           apiClient ??
           ApiClient(client: client, baseUrl: baseUrl, storage: storage);

  final ApiClient _apiClient;

  Future<JockeyDashboardResponse> getDashboard() {
    return _apiClient.getObject(
      '/jockey/dashboard',
      JockeyDashboardResponse.fromJson,
    );
  }

  Future<Map<String, dynamic>> getPerformance() {
    return _apiClient.getObject('/jockey/performance', (json) => json);
  }
}
