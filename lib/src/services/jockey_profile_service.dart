import 'package:http/http.dart' as http;

import 'api_client.dart';
import 'auth_storage.dart';

class JockeyProfileService {
  JockeyProfileService({
    http.Client? client,
    String? baseUrl,
    AuthStorage? storage,
    ApiClient? apiClient,
  }) : _apiClient =
           apiClient ??
           ApiClient(client: client, baseUrl: baseUrl, storage: storage);

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> getMyProfile() {
    return _apiClient.getObject('/jockey/profile', (json) => json);
  }

  Future<Map<String, dynamic>> updateMyProfile({
    required Map<String, String> fields,
    Map<String, String> filePaths = const {},
  }) {
    return _apiClient.multipartObject(
      'PUT',
      '/jockey/profile',
      fields,
      filePaths,
      (json) => json,
    );
  }
}
