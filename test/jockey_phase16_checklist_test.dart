import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:horse_racing/src/models/auth_session.dart';
import 'package:horse_racing/src/models/deposit_order_response.dart';
import 'package:horse_racing/src/models/jockey_dashboard_response.dart';
import 'package:horse_racing/src/models/jockey_invitation_response.dart';
import 'package:horse_racing/src/models/jockey_performance_response.dart';
import 'package:horse_racing/src/models/jockey_race_response.dart';
import 'package:horse_racing/src/models/jockey_race_result_response.dart';
import 'package:horse_racing/src/models/notification_response.dart';
import 'package:horse_racing/src/models/unread_notification_count_response.dart';
import 'package:horse_racing/src/models/wallet_response.dart';
import 'package:horse_racing/src/models/wallet_transaction_response.dart';
import 'package:horse_racing/src/models/withdrawal_response.dart';
import 'package:horse_racing/src/services/api_client.dart';
import 'package:horse_racing/src/services/api_exception.dart';
import 'package:horse_racing/src/services/auth_storage.dart';
import 'package:horse_racing/src/services/jockey_notification_service.dart';
import 'package:horse_racing/src/services/jockey_wallet_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 16 service checklist gaps', () {
    test(
      'wallet service sends API headers and keeps 403 validation message',
      () async {
        final storage = await _storageWithToken('phase16-wallet-token');
        final service = JockeyWalletService(
          baseUrl: 'http://example.test',
          storage: storage,
          client: MockClient((request) async {
            expect(request.method, 'POST');
            expect(
              request.url.toString(),
              'http://example.test/wallets/me/withdrawals',
            );
            expect(request.headers['Accept'], 'application/json');
            expect(
              request.headers['Authorization'],
              'Bearer phase16-wallet-token',
            );
            expect(request.headers['Content-Type'], 'application/json');
            expect(jsonDecode(request.body), {
              'amount': 99999999,
              'bankName': 'VCB',
              'bankAccountNumber': '123456',
              'bankAccountName': 'NGUYEN VAN A',
            });
            return _apiResponse(
              success: false,
              statusCode: 403,
              data: {
                'amount': ['Insufficient available balance'],
              },
            );
          }),
        );

        await expectLater(
          service.createWithdrawal(
            amount: 99999999,
            bankName: ' VCB ',
            bankAccountNumber: ' 123456 ',
            bankAccountName: ' NGUYEN VAN A ',
          ),
          throwsA(
            isA<ApiException>()
                .having((error) => error.statusCode, 'statusCode', 403)
                .having(
                  (error) => error.message,
                  'message',
                  'Insufficient available balance',
                ),
          ),
        );
      },
    );

    test(
      'notification service parses an empty typed page with auth headers',
      () async {
        final storage = await _storageWithToken('phase16-notification-token');
        final service = JockeyNotificationService(
          baseUrl: 'http://example.test',
          storage: storage,
          client: MockClient((request) async {
            expect(request.method, 'GET');
            expect(request.url.path, '/notifications');
            expect(request.url.queryParameters['page'], '0');
            expect(request.url.queryParameters['size'], '20');
            expect(request.headers['Accept'], 'application/json');
            expect(
              request.headers['Authorization'],
              'Bearer phase16-notification-token',
            );
            return _apiResponse(
              data: {
                'content': [],
                'totalElements': '0',
                'totalPages': '0',
                'number': '0',
                'size': '20',
              },
            );
          }),
        );

        final page = await service.getNotifications();

        expect(page.content, isEmpty);
        expect(page.totalElements, 0);
        expect(page.totalPages, 0);
        expect(page.number, 0);
        expect(page.size, 20);
      },
    );

    test(
      'authenticated jockey services fail fast when token is missing',
      () async {
        SharedPreferences.setMockInitialValues({});
        final preferences = await SharedPreferences.getInstance();
        final service = JockeyWalletService(
          baseUrl: 'http://example.test',
          storage: AuthStorage(preferences: preferences),
          client: MockClient(
            (_) async => http.Response('should-not-call', 500),
          ),
        );

        await expectLater(service.getWallet(), throwsA(isA<ApiException>()));
      },
    );
  });

  group('Phase 16 model parse checklist gaps', () {
    test('dashboard response tolerates missing collections and mixed ids', () {
      final response = JockeyDashboardResponse.fromJson({
        'role': 'JOCKEY',
        'account': {'username': 'minh'},
        'businessSummary': {
          'invitationsByStatus': {'PENDING': '4'},
        },
        'alerts': [
          {'type': 'WALLET', 'id': '31', 'title': 'Wallet updated'},
        ],
        'upcoming': [
          {'id': 22, 'title': 'Autumn Sprint', 'at': 'bad-date'},
        ],
        'quickLinks': [
          {'label': 'Wallet', 'route': '/jockey/wallet', 'enabled': true},
          {'label': 'Disabled', 'route': '/disabled', 'enabled': false},
        ],
      });

      expect(response.pendingInvitationCount, 4);
      expect(response.alerts.single.id, 31);
      expect(response.upcoming.single.at, isNull);
      expect(response.quickLinks.first.route, '/jockey/wallet');
      expect(response.quickLinks.last.enabled, isFalse);
    });

    test('jockey core response models default empty/null fields safely', () {
      final invitation = JockeyInvitationResponse.fromJson(const {});
      final race = JockeyRaceResponse.fromJson(const {});
      final raceResult = JockeyRaceResultResponse.fromJson(const {});
      final standing = JockeyChallengeStandingResponse.fromJson(const {});
      final performance = JockeyPerformanceResponse.fromJson(const {});

      expect(invitation.idString, '');
      expect(invitation.statusCode, 'UNKNOWN');
      expect(race.id, '');
      expect(race.participantCount, 0);
      expect(race.prizes, isEmpty);
      expect(raceResult.rank, 0);
      expect(raceResult.finishTimeMillis, 0);
      expect(standing.challengeRank, 0);
      expect(standing.totalPoints, 0);
      expect(performance.raceCount, 0);
      expect(performance.recentRaces, isEmpty);
    });

    test('wallet and notification models default empty/null fields safely', () {
      final wallet = WalletResponse.fromJson(const {
        'availableBalance': '10',
        'holdBalance': '5',
      });
      final transaction = WalletTransactionResponse.fromJson(const {});
      final deposit = DepositOrderResponse.fromJson(const {});
      final withdrawal = WithdrawalResponse.fromJson(const {});
      final notification = NotificationResponse.fromJson(const {});
      final unread = UnreadNotificationCountResponse.fromJson(const {
        'count': '7',
      });
      final page = ApiPage<NotificationResponse>.fromJson(const {
        'content': [
          {'id': 1, 'title': 'Race', 'message': 'Ready'},
        ],
        'totalElements': '1',
        'totalPages': '1',
        'number': '0',
        'size': '20',
      }, NotificationResponse.fromJson);

      expect(wallet.id, '');
      expect(wallet.currency, 'VND');
      expect(wallet.totalBalance, 15);
      expect(transaction.amount, 0);
      expect(deposit.currency, 'VND');
      expect(withdrawal.bankName, '');
      expect(notification.title, isNotEmpty);
      expect(notification.isRead, isFalse);
      expect(unread.count, 7);
      expect(page.content.single.id, '1');
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

http.Response _apiResponse({
  bool success = true,
  String message = '',
  Object? data,
  int statusCode = 200,
}) {
  return http.Response.bytes(
    utf8.encode(
      jsonEncode({'success': success, 'message': message, 'data': data}),
    ),
    statusCode,
  );
}
