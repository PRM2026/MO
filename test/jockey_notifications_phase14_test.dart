import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horse_racing/src/models/auth_session.dart';
import 'package:horse_racing/src/models/notification_response.dart';
import 'package:horse_racing/src/models/unread_notification_count_response.dart';
import 'package:horse_racing/src/repositories/jockey_notification_repository.dart';
import 'package:horse_racing/src/services/api_client.dart';
import 'package:horse_racing/src/services/api_exception.dart';
import 'package:horse_racing/src/services/auth_storage.dart';
import 'package:horse_racing/src/services/jockey_notification_service.dart';
import 'package:horse_racing/src/viewmodels/jockey_notifications_viewmodel.dart';
import 'package:horse_racing/src/views/jockey/jockey_notifications_screen.dart';
import 'package:horse_racing/src/widgets/jockey/jockey_app_bar.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Jockey notification service', () {
    test(
      'calls page, count and mutation endpoints with typed responses',
      () async {
        final storage = await _storageWithToken('jockey-notification-token');
        final requests = <http.Request>[];
        final service = JockeyNotificationService(
          baseUrl: 'http://example.test',
          storage: storage,
          client: MockClient((request) async {
            requests.add(request);
            expect(
              request.headers['Authorization'],
              'Bearer jockey-notification-token',
            );

            final path = request.url.path;
            if (request.method == 'GET' && path == '/notifications') {
              expect(request.url.queryParameters['status'], 'UNREAD');
              expect(request.url.queryParameters['page'], '1');
              expect(request.url.queryParameters['size'], '20');
              return _success(_pageJson([_notificationJson(id: 10)]));
            }
            if (request.method == 'GET' &&
                path == '/notifications/unread-count') {
              return _success({'count': 3});
            }
            if (request.method == 'PUT' && path == '/notifications/10/read') {
              expect(request.body, '{}');
              return _success(_notificationJson(id: 10, read: true));
            }
            if (request.method == 'PUT' && path == '/notifications/read-all') {
              expect(request.body, '{}');
              return _success({'count': 2});
            }
            return http.Response('not found', 404);
          }),
        );

        final page = await service.getNotifications(status: 'UNREAD', page: 1);
        final count = await service.getUnreadCount();
        final updated = await service.markRead('10');
        final markAll = await service.markAllRead();

        expect(page.content.single.id, '10');
        expect(page.number, 1);
        expect(count.count, 3);
        expect(updated.isRead, isTrue);
        expect(markAll.count, 2);
        expect(requests, hasLength(4));
      },
    );
  });

  group('Jockey notifications viewmodel', () {
    test(
      'initial load, filter reset and load more append unique pages',
      () async {
        final repository = _NotificationRepository(
          pages: {
            'ALL:0': _page([_notification(id: '1')], number: 0, totalPages: 2),
            'ALL:1': _page([_notification(id: '2')], number: 1, totalPages: 2),
            'UNREAD:0': _page(
              [_notification(id: '3')],
              number: 0,
              totalPages: 1,
            ),
          },
          unreadCount: 4,
        );
        final viewModel = JockeyNotificationsViewModel(
          repository: repository,
          pageSize: 20,
        );

        await viewModel.loadInitial();
        expect(viewModel.notifications.map((item) => item.id), ['1']);
        expect(viewModel.unreadCount, 4);
        expect(viewModel.hasMore, isTrue);

        await viewModel.loadMore();
        expect(viewModel.notifications.map((item) => item.id), ['1', '2']);
        expect(repository.pageKeys, ['ALL:0', 'ALL:1']);

        await viewModel.selectFilter(JockeyNotificationFilter.unread);
        expect(viewModel.notifications.map((item) => item.id), ['3']);
        expect(viewModel.currentPage, 0);
        expect(repository.pageKeys.last, 'UNREAD:0');
      },
    );

    test('mark read updates item and unread filter removes it', () async {
      final unread = _notification(id: '5');
      final repository = _NotificationRepository(
        pages: {
          'ALL:0': _page([unread], number: 0, totalPages: 1),
          'UNREAD:0': _page([unread], number: 0, totalPages: 1),
        },
        unreadCount: 2,
        readResponses: {'5': _notification(id: '5', read: true)},
      );
      final viewModel = JockeyNotificationsViewModel(repository: repository);

      await viewModel.loadInitial();
      await viewModel.selectFilter(JockeyNotificationFilter.unread);
      await viewModel.markRead(unread);

      expect(viewModel.unreadCount, 1);
      expect(viewModel.notifications, isEmpty);
      expect(repository.markReadIds, ['5']);
    });

    test(
      'mark all sets unread count to zero and keeps BE updated count ignored',
      () async {
        final repository = _NotificationRepository(
          pages: {
            'ALL:0': _page(
              [_notification(id: '1'), _notification(id: '2', read: true)],
              number: 0,
              totalPages: 1,
            ),
          },
          unreadCount: 3,
          markAllCount: 3,
        );
        final viewModel = JockeyNotificationsViewModel(repository: repository);

        await viewModel.loadInitial();
        await viewModel.markAllRead();

        expect(viewModel.unreadCount, 0);
        expect(viewModel.notifications.every((item) => item.isRead), isTrue);
        expect(repository.markAllCalls, 1);
      },
    );

    test('mutation error keeps list and exposes backend message', () async {
      final item = _notification(id: '9');
      final repository = _NotificationRepository(
        pages: {
          'ALL:0': _page([item], number: 0, totalPages: 1),
        },
        unreadCount: 1,
        markReadError: const ApiException('Notification not found'),
      );
      final viewModel = JockeyNotificationsViewModel(repository: repository);

      await viewModel.loadInitial();
      await viewModel.markRead(item);

      expect(viewModel.notifications.single.id, '9');
      expect(viewModel.unreadCount, 1);
      expect(viewModel.mutationError, 'Notification not found');
    });
  });

  group('Jockey notifications widgets', () {
    testWidgets('renders filters, unread cards, load more and mark all', (
      tester,
    ) async {
      final repository = _NotificationRepository(
        pages: {
          'ALL:0': _page([_notification(id: '1')], number: 0, totalPages: 2),
          'ALL:1': _page(
            [_notification(id: '2', title: 'Deposit paid')],
            number: 1,
            totalPages: 2,
          ),
        },
        unreadCount: 2,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: JockeyNotificationsScreen(
            viewModel: JockeyNotificationsViewModel(repository: repository),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Thông báo của tôi'), findsOneWidget);
      expect(find.text('2 thông báo chưa đọc'), findsOneWidget);
      expect(
        find.byKey(const Key('jockey-notification-unread-1')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('jockey-notification-load-more')));
      await tester.pumpAndSettle();
      expect(find.text('Deposit paid'), findsOneWidget);

      await tester.tap(find.byKey(const Key('jockey-notification-mark-all')));
      await tester.pumpAndSettle();
      expect(find.text('Bạn đã đọc tất cả thông báo.'), findsOneWidget);
    });

    testWidgets(
      'tap unread marks it once; tapping read item does not call API',
      (tester) async {
        final repository = _NotificationRepository(
          pages: {
            'ALL:0': _page(
              [_notification(id: '1'), _notification(id: '2', read: true)],
              number: 0,
              totalPages: 1,
            ),
          },
          unreadCount: 1,
          readResponses: {'1': _notification(id: '1', read: true)},
        );

        await tester.pumpWidget(
          MaterialApp(
            home: JockeyNotificationsScreen(
              viewModel: JockeyNotificationsViewModel(repository: repository),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('jockey-notification-1')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('jockey-notification-2')));
        await tester.pumpAndSettle();

        expect(repository.markReadIds, ['1']);
        expect(
          find.byKey(const Key('jockey-notification-unread-1')),
          findsNothing,
        );
      },
    );

    testWidgets('bell shows badge, opens callback and hides with flag', (
      tester,
    ) async {
      var opened = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: JockeyAppBar(
              notificationUnreadCount: 105,
              onNotificationTap: () async => opened++,
            ),
          ),
        ),
      );

      expect(
        find.byKey(const Key('jockey-notification-badge')),
        findsOneWidget,
      );
      expect(find.text('99+'), findsOneWidget);
      await tester.tap(find.byKey(const Key('jockey-notification-bell')));
      await tester.pumpAndSettle();
      expect(opened, 1);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(appBar: JockeyAppBar(showNotificationAction: false)),
        ),
      );
      expect(find.byKey(const Key('jockey-notification-bell')), findsNothing);
    });
  });
}

Future<AuthStorage> _storageWithToken(String token) async {
  SharedPreferences.setMockInitialValues({});
  final preferences = await SharedPreferences.getInstance();
  final storage = AuthStorage(preferences: preferences);
  await storage.saveSession(
    AuthSession(token: token, tokenType: 'Bearer', role: 'JOCKEY'),
  );
  return storage;
}

http.Response _success(Object data) {
  return http.Response.bytes(
    utf8.encode(
      jsonEncode({'success': true, 'message': 'Success', 'data': data}),
    ),
    200,
  );
}

Map<String, dynamic> _pageJson(List<Map<String, dynamic>> content) => {
  'content': content,
  'totalElements': content.length,
  'totalPages': 2,
  'number': 1,
  'size': 20,
};

Map<String, dynamic> _notificationJson({required int id, bool read = false}) {
  return {
    'id': id,
    'recipientId': 5,
    'recipientUsername': 'jockey01',
    'type': 'INVITATION_CREATED',
    'title': 'New invitation',
    'message': 'You received a jockey invitation',
    'referenceType': 'JOCKEY_INVITATION',
    'referenceId': '77',
    'metadataJson': '{"horseId":3}',
    'readAt': read ? '2026-06-18T10:40:00' : null,
    'createdAt': '2026-06-18T10:30:00',
  };
}

NotificationResponse _notification({
  String id = '1',
  String title = 'New invitation',
  bool read = false,
}) {
  return NotificationResponse(
    id: id,
    type: 'INVITATION_CREATED',
    title: title,
    message: 'You received a jockey invitation',
    referenceType: 'JOCKEY_INVITATION',
    referenceId: '77',
    readAt: read ? DateTime.parse('2026-06-18T10:40:00') : null,
    createdAt: DateTime.parse('2026-06-18T10:30:00'),
  );
}

ApiPage<NotificationResponse> _page(
  List<NotificationResponse> content, {
  required int number,
  required int totalPages,
}) {
  return ApiPage(
    content: content,
    totalElements: content.length,
    totalPages: totalPages,
    number: number,
    size: 20,
  );
}

class _NotificationRepository extends JockeyNotificationRepository {
  _NotificationRepository({
    required this.pages,
    required this.unreadCount,
    this.readResponses = const {},
    this.markReadError,
    this.markAllCount = 0,
  });

  final Map<String, ApiPage<NotificationResponse>> pages;
  final int unreadCount;
  final Map<String, NotificationResponse> readResponses;
  final ApiException? markReadError;
  final int markAllCount;
  final List<String> pageKeys = [];
  final List<String> markReadIds = [];
  int markAllCalls = 0;

  @override
  Future<ApiPage<NotificationResponse>> fetchNotifications({
    String? status,
    int page = 0,
    int size = 20,
  }) async {
    final key = '${status ?? 'ALL'}:$page';
    pageKeys.add(key);
    return pages[key] ??
        ApiPage(
          content: const [],
          totalElements: 0,
          totalPages: 0,
          number: page,
          size: size,
        );
  }

  @override
  Future<UnreadNotificationCountResponse> fetchUnreadCount() async {
    return UnreadNotificationCountResponse(count: unreadCount);
  }

  @override
  Future<NotificationResponse> markRead(String id) async {
    markReadIds.add(id);
    final error = markReadError;
    if (error != null) throw error;
    return readResponses[id] ?? _notification(id: id, read: true);
  }

  @override
  Future<UnreadNotificationCountResponse> markAllRead() async {
    markAllCalls++;
    return UnreadNotificationCountResponse(count: markAllCount);
  }
}
