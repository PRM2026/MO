import 'package:http/http.dart' as http;

import '../models/jockey_profile_response.dart';
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

  Future<JockeyProfileResponse> getMyProfile() {
    return _apiClient.getObject(
      '/jockey/profile',
      JockeyProfileResponse.fromJson,
    );
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
