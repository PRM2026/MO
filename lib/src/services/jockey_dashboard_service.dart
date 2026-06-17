import 'package:http/http.dart' as http;

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

  Future<Map<String, dynamic>> getDashboard() {
    return _apiClient.getObject('/jockey/dashboard', (json) => json);
  }

  Future<Map<String, dynamic>> getPerformance() {
    return _apiClient.getObject('/jockey/performance', (json) => json);
  }
}
