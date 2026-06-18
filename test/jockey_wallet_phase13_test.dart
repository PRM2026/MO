import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horse_racing/src/models/auth_session.dart';
import 'package:horse_racing/src/models/deposit_order_response.dart';
import 'package:horse_racing/src/models/jockey_wallet_data.dart';
import 'package:horse_racing/src/models/wallet_response.dart';
import 'package:horse_racing/src/models/wallet_transaction_response.dart';
import 'package:horse_racing/src/models/withdrawal_response.dart';
import 'package:horse_racing/src/repositories/jockey_wallet_repository.dart';
import 'package:horse_racing/src/services/api_exception.dart';
import 'package:horse_racing/src/services/auth_storage.dart';
import 'package:horse_racing/src/services/jockey_wallet_service.dart';
import 'package:horse_racing/src/viewmodels/jockey_deposit_viewmodel.dart';
import 'package:horse_racing/src/viewmodels/jockey_wallet_viewmodel.dart';
import 'package:horse_racing/src/viewmodels/jockey_withdrawal_viewmodel.dart';
import 'package:horse_racing/src/views/jockey/jockey_deposit_screen.dart';
import 'package:horse_racing/src/views/jockey/jockey_wallet_screen.dart';
import 'package:horse_racing/src/views/jockey/jockey_withdrawal_screen.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Jockey wallet service', () {
    test('uses all wallet endpoints with typed responses and token', () async {
      final storage = await _storageWithToken('jockey-wallet-token');
      final requests = <http.Request>[];
      final service = JockeyWalletService(
        baseUrl: 'http://example.test',
        storage: storage,
        client: MockClient((request) async {
          requests.add(request);
          expect(
            request.headers['Authorization'],
            'Bearer jockey-wallet-token',
          );

          final path = request.url.path;
          if (request.method == 'GET' && path == '/wallets/me') {
            return _success(_walletJson());
          }
          if (request.method == 'GET' && path == '/wallets/me/transactions') {
            return _success([_transactionJson()]);
          }
          if (request.method == 'POST' &&
              path == '/wallets/me/deposit-orders') {
            final body = jsonDecode(request.body) as Map<String, dynamic>;
            expect(body, {'amount': 100000, 'currency': 'VND'});
            expect(body.containsKey('provider'), isFalse);
            return _success(_depositJson());
          }
          if (request.method == 'GET' && path == '/wallets/me/deposit-orders') {
            return _success([_depositJson()]);
          }
          if (request.method == 'GET' &&
              path == '/wallets/me/deposit-orders/31') {
            return _success(_depositJson());
          }
          if (request.method == 'POST' && path == '/wallets/me/withdrawals') {
            final body = jsonDecode(request.body) as Map<String, dynamic>;
            expect(body, {
              'amount': 50000,
              'bankName': 'VCB',
              'bankAccountNumber': '123456',
              'bankAccountName': 'NGUYEN VAN A',
              'reason': 'Personal',
            });
            return _success(_withdrawalJson());
          }
          if (request.method == 'GET' && path == '/wallets/me/withdrawals') {
            return _success([_withdrawalJson()]);
          }
          if (request.method == 'GET' && path == '/wallets/me/withdrawals/41') {
            return _success(_withdrawalJson());
          }
          return http.Response('not found', 404);
        }),
      );

      final wallet = await service.getWallet();
      final transactions = await service.getTransactions();
      final createdDeposit = await service.createDepositOrder(amount: 100000);
      final deposits = await service.getDepositOrders();
      final deposit = await service.getDepositOrder('31');
      final createdWithdrawal = await service.createWithdrawal(
        amount: 50000,
        bankName: ' VCB ',
        bankAccountNumber: ' 123456 ',
        bankAccountName: ' NGUYEN VAN A ',
        reason: ' Personal ',
      );
      final withdrawals = await service.getWithdrawals();
      final withdrawal = await service.getWithdrawal('41');

      expect(wallet.availableBalance, 900000);
      expect(transactions.single.type, 'JOCKEY_PAYOUT');
      expect(createdDeposit.checkoutUrl, 'https://pay.example/31');
      expect(deposits.single.id, '31');
      expect(deposit.qrCode, 'qr-payload');
      expect(createdWithdrawal.status, 'PENDING');
      expect(withdrawals.single.bankName, 'VCB');
      expect(withdrawal.id, '41');
      expect(requests, hasLength(8));
    });
  });

  group('Jockey wallet repository and viewmodels', () {
    test('loads four sources and sorts all histories newest first', () async {
      final service = _WalletService(
        wallet: _wallet(),
        transactions: [
          _transaction(id: '1', createdAt: '2026-06-17T10:00:00'),
          _transaction(id: '2', createdAt: '2026-06-18T10:00:00'),
        ],
        deposits: [
          _deposit(id: '1', createdAt: '2026-06-16T10:00:00'),
          _deposit(id: '2', createdAt: '2026-06-18T10:00:00'),
        ],
        withdrawals: [
          _withdrawal(id: '1', createdAt: '2026-06-15T10:00:00'),
          _withdrawal(id: '2', createdAt: '2026-06-18T10:00:00'),
        ],
      );

      final data = await JockeyWalletRepository(service: service).fetchWallet();

      expect(service.walletCalls, 1);
      expect(service.transactionCalls, 1);
      expect(service.depositCalls, 1);
      expect(service.withdrawalCalls, 1);
      expect(data.transactions.map((item) => item.id), ['2', '1']);
      expect(data.depositOrders.map((item) => item.id), ['2', '1']);
      expect(data.withdrawals.map((item) => item.id), ['2', '1']);
    });

    test('wallet viewmodel retries after a failed load', () async {
      final repository = _RetryWalletRepository(_walletData());
      final viewModel = JockeyWalletViewModel(repository: repository);

      await viewModel.loadWallet();
      expect(viewModel.data, isNull);
      expect(viewModel.errorMessage, 'Backend unavailable');

      await viewModel.loadWallet();
      expect(viewModel.data?.wallet.id, '8');
      expect(viewModel.errorMessage, isNull);
      expect(repository.calls, 2);
    });

    test('deposit validates whole VND and prevents duplicate submit', () async {
      final repository = _DelayedDepositRepository();
      final viewModel = JockeyDepositViewModel(repository: repository);

      expect(viewModel.validateAmount('1.5'), 'Số tiền phải là số nguyên VND.');
      final first = viewModel.submit('100000');
      final duplicate = await viewModel.submit('100000');
      expect(duplicate, isNull);
      expect(repository.calls, 1);

      repository.complete(_deposit());
      expect((await first)?.id, '31');
    });

    test('withdrawal keeps backend insufficient-balance message', () async {
      final viewModel = JockeyWithdrawalViewModel(
        repository: _FailingWithdrawalRepository(),
      );

      final result = await viewModel.submit(
        const JockeyWithdrawalInput(
          amount: '99999999',
          bankName: 'VCB',
          bankAccountNumber: '123456',
          bankAccountName: 'NGUYEN VAN A',
          reason: '',
        ),
      );

      expect(result, isNull);
      expect(viewModel.errorMessage, 'Insufficient available balance');
    });
  });

  group('Jockey wallet widgets', () {
    testWidgets('shows balance, three tabs and their empty states', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(390, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          home: JockeyWalletScreen(
            viewModel: JockeyWalletViewModel(
              repository: _DataWalletRepository(_walletData()),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ví của tôi'), findsOneWidget);
      expect(find.text('Giao dịch'), findsOneWidget);
      expect(find.text('Lệnh nạp'), findsOneWidget);
      expect(find.text('Rút tiền'), findsWidgets);
      expect(find.text('Chưa có giao dịch nào.'), findsOneWidget);

      await tester.tap(find.byKey(const Key('jockey-wallet-tab-deposits')));
      await tester.pumpAndSettle();
      expect(find.text('Chưa có lệnh nạp tiền nào.'), findsOneWidget);

      await tester.tap(find.byKey(const Key('jockey-wallet-tab-withdrawals')));
      await tester.pumpAndSettle();
      expect(find.text('Chưa có yêu cầu rút tiền nào.'), findsOneWidget);
    });

    testWidgets('deposit validates then renders QR and payment values', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: JockeyDepositScreen(
            viewModel: JockeyDepositViewModel(
              repository: _DepositRepository(_deposit()),
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('jockey-deposit-submit')));
      await tester.pump();
      expect(find.text('Vui lòng nhập số tiền.'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('jockey-deposit-amount')),
        '100000',
      );
      await tester.tap(find.byKey(const Key('jockey-deposit-submit')));
      await tester.pumpAndSettle();

      expect(find.byType(QrImageView), findsOneWidget);
      expect(find.text('https://pay.example/31'), findsOneWidget);
      expect(find.text('HORSE DEP-31'), findsOneWidget);
      expect(find.byKey(const Key('jockey-deposit-done')), findsOneWidget);
    });

    testWidgets('withdrawal validates and shows pending confirmation', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: JockeyWithdrawalScreen(
            viewModel: JockeyWithdrawalViewModel(
              repository: _WithdrawalRepository(_withdrawal()),
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('jockey-withdrawal-submit')));
      await tester.pump();
      expect(find.text('Vui lòng nhập số tiền.'), findsOneWidget);

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), '50000');
      await tester.enterText(fields.at(1), 'VCB');
      await tester.enterText(fields.at(2), '123456');
      await tester.enterText(fields.at(3), 'NGUYEN VAN A');
      await tester.tap(find.byKey(const Key('jockey-withdrawal-submit')));
      await tester.pumpAndSettle();

      expect(find.textContaining('Yêu cầu #41'), findsOneWidget);
      expect(find.textContaining('PENDING'), findsOneWidget);
      expect(find.byKey(const Key('jockey-withdrawal-done')), findsOneWidget);
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

Map<String, dynamic> _walletJson() => {
  'id': 8,
  'ownerType': 'USER',
  'userId': 5,
  'currency': 'VND',
  'availableBalance': 900000,
  'holdBalance': 100000,
  'totalBalance': 1000000,
  'status': 'ACTIVE',
  'createdAt': '2026-06-01T10:00:00',
};

Map<String, dynamic> _transactionJson() => {
  'id': 11,
  'walletId': 8,
  'userId': 5,
  'type': 'JOCKEY_PAYOUT',
  'direction': 'CREDIT',
  'amount': 500000,
  'status': 'SUCCESS',
  'createdAt': '2026-06-18T10:00:00',
};

Map<String, dynamic> _depositJson() => {
  'id': 31,
  'userId': 5,
  'amount': 100000,
  'currency': 'VND',
  'provider': 'ZALOPAY',
  'status': 'PENDING',
  'referenceCode': 'DEP-31',
  'checkoutUrl': 'https://pay.example/31',
  'qrCode': 'qr-payload',
  'transferContent': 'HORSE DEP-31',
  'expiredAt': '2026-06-18T11:00:00',
  'createdAt': '2026-06-18T10:30:00',
};

Map<String, dynamic> _withdrawalJson() => {
  'id': 41,
  'userId': 5,
  'amount': 50000,
  'currency': 'VND',
  'status': 'PENDING',
  'bankName': 'VCB',
  'bankAccountNumber': '123456',
  'bankAccountName': 'NGUYEN VAN A',
  'reason': 'Personal',
  'createdAt': '2026-06-18T10:45:00',
};

WalletResponse _wallet({String status = 'ACTIVE'}) {
  return WalletResponse.fromJson({..._walletJson(), 'status': status});
}

WalletTransactionResponse _transaction({
  String id = '11',
  String createdAt = '2026-06-18T10:00:00',
}) {
  return WalletTransactionResponse.fromJson({
    ..._transactionJson(),
    'id': id,
    'createdAt': createdAt,
  });
}

DepositOrderResponse _deposit({
  String id = '31',
  String createdAt = '2026-06-18T10:30:00',
}) {
  return DepositOrderResponse.fromJson({
    ..._depositJson(),
    'id': id,
    'createdAt': createdAt,
  });
}

WithdrawalResponse _withdrawal({
  String id = '41',
  String createdAt = '2026-06-18T10:45:00',
}) {
  return WithdrawalResponse.fromJson({
    ..._withdrawalJson(),
    'id': id,
    'createdAt': createdAt,
  });
}

JockeyWalletData _walletData() {
  return JockeyWalletData(
    wallet: _wallet(),
    transactions: const [],
    depositOrders: const [],
    withdrawals: const [],
  );
}

class _WalletService extends JockeyWalletService {
  _WalletService({
    required this.wallet,
    required this.transactions,
    required this.deposits,
    required this.withdrawals,
  });

  final WalletResponse wallet;
  final List<WalletTransactionResponse> transactions;
  final List<DepositOrderResponse> deposits;
  final List<WithdrawalResponse> withdrawals;
  int walletCalls = 0;
  int transactionCalls = 0;
  int depositCalls = 0;
  int withdrawalCalls = 0;

  @override
  Future<WalletResponse> getWallet() async {
    walletCalls++;
    return wallet;
  }

  @override
  Future<List<WalletTransactionResponse>> getTransactions() async {
    transactionCalls++;
    return transactions;
  }

  @override
  Future<List<DepositOrderResponse>> getDepositOrders() async {
    depositCalls++;
    return deposits;
  }

  @override
  Future<List<WithdrawalResponse>> getWithdrawals() async {
    withdrawalCalls++;
    return withdrawals;
  }
}

class _DataWalletRepository extends JockeyWalletRepository {
  _DataWalletRepository(this.value);

  final JockeyWalletData value;

  @override
  Future<JockeyWalletData> fetchWallet() async => value;
}

class _RetryWalletRepository extends JockeyWalletRepository {
  _RetryWalletRepository(this.value);

  final JockeyWalletData value;
  int calls = 0;

  @override
  Future<JockeyWalletData> fetchWallet() async {
    calls++;
    if (calls == 1) {
      throw const ApiException('Backend unavailable');
    }
    return value;
  }
}

class _DelayedDepositRepository extends JockeyWalletRepository {
  final _completer = Completer<DepositOrderResponse>();
  int calls = 0;

  @override
  Future<DepositOrderResponse> createDepositOrder({required int amount}) {
    calls++;
    return _completer.future;
  }

  void complete(DepositOrderResponse value) => _completer.complete(value);
}

class _DepositRepository extends JockeyWalletRepository {
  _DepositRepository(this.value);

  final DepositOrderResponse value;

  @override
  Future<DepositOrderResponse> createDepositOrder({required int amount}) async {
    return value;
  }
}

class _FailingWithdrawalRepository extends JockeyWalletRepository {
  @override
  Future<WithdrawalResponse> createWithdrawal({
    required num amount,
    required String bankName,
    required String bankAccountNumber,
    required String bankAccountName,
    String? reason,
  }) {
    throw const ApiException('Insufficient available balance');
  }
}

class _WithdrawalRepository extends JockeyWalletRepository {
  _WithdrawalRepository(this.value);

  final WithdrawalResponse value;

  @override
  Future<WithdrawalResponse> createWithdrawal({
    required num amount,
    required String bankName,
    required String bankAccountNumber,
    required String bankAccountName,
    String? reason,
  }) async {
    return value;
  }
}
