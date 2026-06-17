import 'package:http/http.dart' as http;

import 'api_client.dart';
import 'auth_storage.dart';

class JockeyNotificationService {
  JockeyNotificationService({
    http.Client? client,
    String? baseUrl,
    AuthStorage? storage,
    ApiClient? apiClient,
  }) : _apiClient =
           apiClient ??
           ApiClient(client: client, baseUrl: baseUrl, storage: storage);

  final ApiClient _apiClient;

  Future<ApiPage<Map<String, dynamic>>> getNotifications({
    String? status,
    int page = 0,
    int size = 20,
  }) {
    final query = <String>[
      if (status != null && status.trim().isNotEmpty) 'status=${status.trim()}',
      'page=$page',
      'size=$size',
    ].join('&');
    return _apiClient.getPage('/notifications?$query', (json) => json);
  }

  Future<Map<String, dynamic>> getUnreadCount() {
    return _apiClient.getObject('/notifications/unread-count', (json) => json);
  }

  Future<Map<String, dynamic>> markRead(String id) {
    return _apiClient.putObject('/notifications/$id/read', {}, (json) => json);
  }

  Future<Map<String, dynamic>> markAllRead() {
    return _apiClient.putObject('/notifications/read-all', {}, (json) => json);
  }
}
