import 'package:http/http.dart' as http;

import '../models/notification_response.dart';
import '../models/unread_notification_count_response.dart';
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

  Future<ApiPage<NotificationResponse>> getNotifications({
    String? status,
    int page = 0,
    int size = 20,
  }) {
    final query = <String>[
      if (status != null && status.trim().isNotEmpty) 'status=${status.trim()}',
      'page=$page',
      'size=$size',
    ].join('&');
    return _apiClient.getPage(
      '/notifications?$query',
      NotificationResponse.fromJson,
    );
  }

  Future<UnreadNotificationCountResponse> getUnreadCount() {
    return _apiClient.getObject(
      '/notifications/unread-count',
      UnreadNotificationCountResponse.fromJson,
    );
  }

  Future<NotificationResponse> markRead(String id) {
    return _apiClient.putObject(
      '/notifications/$id/read',
      {},
      NotificationResponse.fromJson,
    );
  }

  Future<UnreadNotificationCountResponse> markAllRead() {
    return _apiClient.putObject(
      '/notifications/read-all',
      {},
      UnreadNotificationCountResponse.fromJson,
    );
  }
}
