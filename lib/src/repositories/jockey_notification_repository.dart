import '../models/notification_response.dart';
import '../models/unread_notification_count_response.dart';
import '../services/api_client.dart';
import '../services/jockey_notification_service.dart';

class JockeyNotificationRepository {
  JockeyNotificationRepository({JockeyNotificationService? service})
    : _service = service ?? JockeyNotificationService();

  final JockeyNotificationService _service;

  Future<ApiPage<NotificationResponse>> fetchNotifications({
    String? status,
    int page = 0,
    int size = 20,
  }) {
    return _service.getNotifications(status: status, page: page, size: size);
  }

  Future<UnreadNotificationCountResponse> fetchUnreadCount() {
    return _service.getUnreadCount();
  }

  Future<NotificationResponse> markRead(String id) {
    return _service.markRead(id);
  }

  Future<UnreadNotificationCountResponse> markAllRead() {
    return _service.markAllRead();
  }
}
