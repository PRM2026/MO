import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horse_racing/src/models/auth_session.dart';
import 'package:horse_racing/src/models/jockey_performance_response.dart';
import 'package:horse_racing/src/models/jockey_race_response.dart';
import 'package:horse_racing/src/models/jockey_race_result_response.dart';
import 'package:horse_racing/src/models/jockey_results_data.dart';
import 'package:horse_racing/src/models/wallet_transaction_response.dart';
import 'package:horse_racing/src/repositories/jockey_results_repository.dart';
import 'package:horse_racing/src/services/auth_storage.dart';
import 'package:horse_racing/src/services/jockey_dashboard_service.dart';
import 'package:horse_racing/src/services/jockey_race_service.dart';
import 'package:horse_racing/src/services/jockey_wallet_service.dart';
import 'package:horse_racing/src/viewmodels/jockey_results_viewmodel.dart';
import 'package:horse_racing/src/views/jockey/jockey_results_screen.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Jockey prize service', () {
    test(
      'calls jockey prizes endpoint with token and parses transactions',
      () async {
        final storage = await _storageWithToken('jockey-token');
        final service = JockeyWalletService(
          baseUrl: 'http://example.test',
          storage: storage,
          client: MockClient((request) async {
            expect(request.method, 'GET');
            expect(request.url.toString(), 'http://example.test/jockey/prizes');
            expect(request.headers['Authorization'], 'Bearer jockey-token');
            return http.Response.bytes(
              utf8.encode(
                jsonEncode({
                  'success': true,
                  'message': 'Success',
                  'data': [
                    {
                      'id': 91,
                      'walletId': 8,
                      'userId': 5,
                      'type': 'JOCKEY_PAYOUT',
                      'direction': 'CREDIT',
                      'amount': 2500000,
                      'status': 'SUCCESS',
                      'referenceType': 'RACE',
                      'referenceId': '22',
                      'note': 'Race remuneration',
                      'createdAt': '2026-06-18T10:30:00',
                    },
                  ],
                }),
              ),
              200,
            );
          }),
        );

        final prizes = await service.getJockeyPrizes();

        expect(prizes, hasLength(1));
        expect(prizes.single.id, '91');
        expect(prizes.single.type, 'JOCKEY_PAYOUT');
        expect(prizes.single.amount, 2500000);
        expect(prizes.single.referenceId, '22');
        expect(prizes.single.createdAt, DateTime.parse('2026-06-18T10:30:00'));
      },
    );
  });

  group('Jockey results repository', () {
    test(
      'loads three sources, requests only finalized results, filters jockey and sorts',
      () async {
        final dashboardService = _DashboardService(_performance());
        final raceService = _RaceService(
          [
            _race(
              id: '10',
              name: 'Older finalized',
              status: 'RESULT_CONFIRMED',
              date: '2026-06-10T08:00:00',
            ),
            _race(
              id: '11',
              name: 'Newest pending',
              status: 'SCHEDULED',
              date: '2026-06-20T08:00:00',
            ),
            _race(
              id: '12',
              name: 'Newest finalized',
              status: 'RESULT_CONFIRMED',
              date: '2026-06-18T08:00:00',
            ),
          ],
          {
            '10': [_result(raceId: 10, jockeyId: 99, rank: 1)],
            '12': [
              _result(raceId: 12, jockeyId: 99, rank: 1),
              _result(raceId: 12, jockeyId: 5, rank: 2),
            ],
          },
        );
        final walletService = _WalletService([_prize()]);
        final repository = JockeyResultsRepository(
          dashboardService: dashboardService,
          raceService: raceService,
          walletService: walletService,
        );

        final data = await repository.fetchResults();

        expect(dashboardService.calls, 1);
        expect(walletService.calls, 1);
        expect(raceService.raceCalls, 1);
        expect(raceService.resultRaceIds, ['10', '12']);
        expect(data.results.map((item) => item.raceId), ['11', '12', '10']);
        expect(data.results[0].resultState, JockeyRaceResultState.pending);
        expect(data.results[1].rankLabel, 'Hạng 2');
        expect(data.results[2].resultState, JockeyRaceResultState.missing);
      },
    );

    test('fails the complete load when a required source fails', () async {
      final repository = JockeyResultsRepository(
        dashboardService: _FailingDashboardService(),
        raceService: _RaceService(const [], const {}),
        walletService: _WalletService(const []),
      );

      expect(repository.fetchResults(), throwsException);
    });
  });

  group('Jockey results mapping', () {
    test(
      'maps zero KPI, pending race, missing result and optional prize fields',
      () {
        final data = JockeyResultsData.fromApi(
          performance: JockeyPerformanceResponse.fromJson(const {}),
          races: [
            _race(
              id: '1',
              name: 'Pending Race',
              status: 'ONGOING',
              date: '2026-06-19T08:00:00',
            ),
            _race(
              id: '2',
              name: 'Final Race',
              status: 'RESULT_CONFIRMED',
              date: '2026-06-18T08:00:00',
            ),
          ],
          jockeyResultsByRaceId: const {'2': null},
          prizes: [
            WalletTransactionResponse.fromJson({
              'id': 1,
              'amount': '500000',
              'type': 'PRIZE_PAYOUT',
            }),
          ],
        );

        expect(data.stats.first.value, '0');
        expect(data.results.first.rankLabel, 'Chờ kết quả');
        expect(data.results.last.rankLabel, 'Chưa có kết quả');
        expect(data.prizes.single.amountLabel, '+500.000 đ');
        expect(data.prizes.single.referenceLabel, 'Không có tham chiếu');
        expect(data.prizes.single.createdAtLabel, 'Chưa cập nhật thời gian');
      },
    );
  });

  group('Jockey results screen', () {
    testWidgets('renders KPI, result states, payout and race taps', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1200, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      JockeyRaceResultItem? tapped;

      await tester.pumpWidget(
        MaterialApp(
          home: JockeyResultsScreen(
            viewModel: JockeyResultsViewModel(
              repository: _DataRepository(_screenData()),
            ),
            onRaceTap: (item) => tapped = item,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Kết quả và thanh toán'), findsOneWidget);
      expect(find.text('5 / 2 / 1'), findsOneWidget);
      expect(find.text('Autumn Sprint'), findsOneWidget);
      expect(find.text('Hạng 1'), findsOneWidget);
      expect(find.text('Chờ kết quả'), findsOneWidget);
      expect(find.text('Thanh toán jockey'), findsOneWidget);
      expect(find.text('+2.500.000 đ'), findsOneWidget);
      expect(find.text('RACE #22'), findsOneWidget);

      await tester.tap(find.byKey(const Key('jockey-result-22')));
      expect(tapped?.raceId, '22');
      expect(tapped?.hasResult, isTrue);
    });

    testWidgets('renders separate race and payout empty states', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: JockeyResultsScreen(
            viewModel: JockeyResultsViewModel(
              repository: _DataRepository(
                JockeyResultsData.fromApi(
                  performance: _performance(),
                  races: const [],
                  jockeyResultsByRaceId: const {},
                  prizes: const [],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Chưa có cuộc đua nào được phân công.'), findsOneWidget);
      expect(
        find.text('Chưa có khoản thưởng hoặc thù lao nào.'),
        findsOneWidget,
      );
    });

    testWidgets('shows error then retries without sample fallback', (
      tester,
    ) async {
      final repository = _RetryRepository(_screenData());

      await tester.pumpWidget(
        MaterialApp(
          home: JockeyResultsScreen(
            viewModel: JockeyResultsViewModel(repository: repository),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Khong the tai ket qua va thanh tich.'), findsOneWidget);
      expect(find.text('Autumn Sprint'), findsNothing);

      await tester.tap(find.text('Thử lại'));
      await tester.pumpAndSettle();

      expect(find.text('Autumn Sprint'), findsOneWidget);
      expect(repository.calls, 2);
    });
  });
}

JockeyResultsData _screenData() {
  return JockeyResultsData.fromApi(
    performance: _performance(),
    races: [
      _race(
        id: '22',
        name: 'Autumn Sprint',
        status: 'RESULT_CONFIRMED',
        date: '2026-06-18T08:00:00',
      ),
      _race(
        id: '23',
        name: 'Summer Cup',
        status: 'SCHEDULED',
        date: '2026-06-20T08:00:00',
      ),
    ],
    jockeyResultsByRaceId: {'22': _result(raceId: 22, jockeyId: 5, rank: 1)},
    prizes: [_prize()],
  );
}

JockeyPerformanceResponse _performance() {
  return JockeyPerformanceResponse.fromJson({
    'jockeyId': 5,
    'raceCount': 12,
    'completedRaceCount': 8,
    'firstPlaces': 5,
    'secondPlaces': 2,
    'thirdPlaces': 1,
    'totalJockeyPayout': 15000000,
    'totalPrizePayout': 7500000,
  });
}

JockeyRaceResponse _race({
  required String id,
  required String name,
  required String status,
  required String date,
}) {
  return JockeyRaceResponse(
    id: id,
    tournamentId: '7',
    name: name,
    distance: '1600m',
    venueName: 'Saigon Track',
    provinceName: 'HCMC',
    scheduledStartAt: DateTime.parse(date),
    status: status,
    participantCount: 8,
  );
}

JockeyRaceResultResponse _result({
  required int raceId,
  required int jockeyId,
  required int rank,
}) {
  return JockeyRaceResultResponse(
    id: raceId,
    raceId: raceId,
    participantId: 1,
    ownerId: 2,
    ownerUsername: 'owner01',
    horseId: 3,
    horseName: 'Night Wind',
    jockeyId: jockeyId,
    jockeyUsername: 'jockey$jockeyId',
    rank: rank,
    finishTimeMillis: 102340,
    status: 'FINISHED',
    jockeyChallengePoints: 12,
    jockeyPrizeAmount: 2500000,
    payoutStatus: 'SUCCESS',
  );
}

WalletTransactionResponse _prize() {
  return WalletTransactionResponse.fromJson({
    'id': 91,
    'type': 'JOCKEY_PAYOUT',
    'direction': 'CREDIT',
    'amount': 2500000,
    'status': 'SUCCESS',
    'referenceType': 'RACE',
    'referenceId': '22',
    'note': 'Race remuneration',
    'createdAt': '2026-06-18T10:30:00',
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

class _DashboardService extends JockeyDashboardService {
  _DashboardService(this.performance);

  final JockeyPerformanceResponse performance;
  int calls = 0;

  @override
  Future<JockeyPerformanceResponse> getPerformance() async {
    calls++;
    return performance;
  }
}

class _FailingDashboardService extends JockeyDashboardService {
  @override
  Future<JockeyPerformanceResponse> getPerformance() {
    throw Exception('performance failed');
  }
}

class _RaceService extends JockeyRaceService {
  _RaceService(this.races, this.results);

  final List<JockeyRaceResponse> races;
  final Map<String, List<JockeyRaceResultResponse>> results;
  int raceCalls = 0;
  final List<String> resultRaceIds = [];

  @override
  Future<List<JockeyRaceResponse>> getJockeyRaces() async {
    raceCalls++;
    return races;
  }

  @override
  Future<List<JockeyRaceResultResponse>> getRaceResults(String raceId) async {
    resultRaceIds.add(raceId);
    return results[raceId] ?? const [];
  }
}

class _WalletService extends JockeyWalletService {
  _WalletService(this.prizes);

  final List<WalletTransactionResponse> prizes;
  int calls = 0;

  @override
  Future<List<WalletTransactionResponse>> getJockeyPrizes() async {
    calls++;
    return prizes;
  }
}

class _DataRepository extends JockeyResultsRepository {
  _DataRepository(this.data);

  final JockeyResultsData data;

  @override
  Future<JockeyResultsData> fetchResults() async => data;
}

class _RetryRepository extends JockeyResultsRepository {
  _RetryRepository(this.data);

  final JockeyResultsData data;
  int calls = 0;

  @override
  Future<JockeyResultsData> fetchResults() async {
    calls++;
    if (calls == 1) throw Exception('backend unavailable');
    return data;
  }
}
