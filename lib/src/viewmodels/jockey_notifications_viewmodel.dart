import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../models/notification_response.dart';
import '../repositories/jockey_notification_repository.dart';
import '../services/api_exception.dart';

enum JockeyNotificationFilter {
  all(null, 'Tất cả'),
  unread('UNREAD', 'Chưa đọc'),
  read('READ', 'Đã đọc');

  const JockeyNotificationFilter(this.statusCode, this.label);

  final String? statusCode;
  final String label;
}

class JockeyNotificationsViewModel extends ChangeNotifier {
  JockeyNotificationsViewModel({
    JockeyNotificationRepository? repository,
    this.pageSize = 20,
  }) : _repository = repository ?? JockeyNotificationRepository();

  final JockeyNotificationRepository _repository;
  final int pageSize;

  List<NotificationResponse> notifications = const [];
  JockeyNotificationFilter selectedFilter = JockeyNotificationFilter.all;
  int unreadCount = 0;
  int currentPage = 0;
  int totalPages = 0;
  bool isInitialLoading = false;
  bool isRefreshing = false;
  bool isLoadingMore = false;
  bool isMarkingAll = false;
  String? pageError;
  String? countError;
  String? mutationError;
  final Set<String> processingIds = <String>{};

  bool get hasMore => currentPage + 1 < totalPages;
  bool get canMarkAll => unreadCount > 0 && !isMarkingAll;

  String get emptyMessage {
    return switch (selectedFilter) {
      JockeyNotificationFilter.all => 'Chưa có thông báo nào.',
      JockeyNotificationFilter.unread => 'Bạn không có thông báo chưa đọc.',
      JockeyNotificationFilter.read => 'Bạn chưa có thông báo đã đọc.',
    };
  }

  Future<void> loadInitial() async {
    if (isInitialLoading) return;
    isInitialLoading = true;
    pageError = null;
    countError = null;
    mutationError = null;
    notifyListeners();

    await Future.wait([_loadFirstPage(), _loadUnreadCount()]);

    isInitialLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    if (isRefreshing) return;
    isRefreshing = true;
    pageError = null;
    countError = null;
    mutationError = null;
    notifyListeners();

    await Future.wait([_loadFirstPage(), _loadUnreadCount()]);

    isRefreshing = false;
    notifyListeners();
  }

  Future<void> selectFilter(JockeyNotificationFilter filter) async {
    if (selectedFilter == filter || isInitialLoading || isRefreshing) return;
    selectedFilter = filter;
    notifications = const [];
    currentPage = 0;
    totalPages = 0;
    pageError = null;
    mutationError = null;
    isInitialLoading = true;
    notifyListeners();

    await _loadFirstPage();

    isInitialLoading = false;
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (!hasMore ||
        isLoadingMore ||
        isInitialLoading ||
        isRefreshing ||
        pageError != null) {
      return;
    }

    isLoadingMore = true;
    mutationError = null;
    notifyListeners();

    try {
      final nextPage = currentPage + 1;
      final page = await _repository.fetchNotifications(
        status: selectedFilter.statusCode,
        page: nextPage,
        size: pageSize,
      );
      notifications = _mergeUnique(notifications, page.content);
      currentPage = page.number;
      totalPages = page.totalPages;
    } on ApiException catch (error) {
      mutationError = error.message;
    } catch (error) {
      if (kDebugMode) debugPrint('JockeyNotificationsViewModel more: $error');
      mutationError = 'Không thể tải thêm thông báo.';
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> markRead(NotificationResponse item) async {
    if (item.isRead || processingIds.contains(item.id)) return;
    processingIds.add(item.id);
    mutationError = null;
    notifyListeners();

    try {
      final updated = await _repository.markRead(item.id);
      unreadCount = math.max(0, unreadCount - 1);
      if (selectedFilter == JockeyNotificationFilter.unread) {
        notifications = notifications
            .where((notification) => notification.id != item.id)
            .toList(growable: false);
      } else {
        notifications = notifications
            .map(
              (notification) =>
                  notification.id == item.id ? updated : notification,
            )
            .toList(growable: false);
      }
    } on ApiException catch (error) {
      mutationError = error.message;
    } catch (error) {
      if (kDebugMode) debugPrint('JockeyNotificationsViewModel read: $error');
      mutationError = 'Không thể đánh dấu thông báo đã đọc.';
    } finally {
      processingIds.remove(item.id);
      notifyListeners();
    }
  }

  Future<void> markAllRead() async {
    if (!canMarkAll) return;
    isMarkingAll = true;
    mutationError = null;
    notifyListeners();

    try {
      await _repository.markAllRead();
      unreadCount = 0;
      if (selectedFilter == JockeyNotificationFilter.unread) {
        notifications = const [];
        currentPage = 0;
        totalPages = 0;
      } else {
        final now = DateTime.now();
        notifications = notifications
            .map((item) => item.isRead ? item : item.copyWith(readAt: now))
            .toList(growable: false);
      }
    } on ApiException catch (error) {
      mutationError = error.message;
    } catch (error) {
      if (kDebugMode) debugPrint('JockeyNotificationsViewModel all: $error');
      mutationError = 'Không thể đánh dấu tất cả đã đọc.';
    } finally {
      isMarkingAll = false;
      notifyListeners();
    }
  }

  Future<void> _loadFirstPage() async {
    try {
      final page = await _repository.fetchNotifications(
        status: selectedFilter.statusCode,
        page: 0,
        size: pageSize,
      );
      notifications = page.content;
      currentPage = page.number;
      totalPages = page.totalPages;
      pageError = null;
    } on ApiException catch (error) {
      notifications = const [];
      currentPage = 0;
      totalPages = 0;
      pageError = error.message;
    } catch (error) {
      if (kDebugMode) debugPrint('JockeyNotificationsViewModel page: $error');
      notifications = const [];
      currentPage = 0;
      totalPages = 0;
      pageError = 'Không thể tải thông báo. Vui lòng thử lại.';
    }
  }

  Future<void> _loadUnreadCount() async {
    try {
      final response = await _repository.fetchUnreadCount();
      unreadCount = response.count;
      countError = null;
    } on ApiException catch (error) {
      countError = error.message;
    } catch (error) {
      if (kDebugMode) debugPrint('JockeyNotificationsViewModel count: $error');
      countError = 'Không thể cập nhật số thông báo chưa đọc.';
    }
  }
}

List<NotificationResponse> _mergeUnique(
  List<NotificationResponse> current,
  List<NotificationResponse> incoming,
) {
  final values = <String, NotificationResponse>{
    for (final item in current) item.id: item,
  };
  for (final item in incoming) {
    values[item.id] = item;
  }
  return values.values.toList(growable: false);
}
