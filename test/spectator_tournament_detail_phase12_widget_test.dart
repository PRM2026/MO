import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horse_racing/src/models/spectator_models.dart';
import 'package:horse_racing/src/viewmodels/spectator_home_viewmodel.dart';
import 'package:horse_racing/src/viewmodels/spectator_tournament_detail_viewmodel.dart';
import 'package:horse_racing/src/views/spectator/spectator_home_screen.dart';
import 'package:horse_racing/src/views/spectator/spectator_tournament_detail_screen.dart';

void main() {
  testWidgets('tournament detail renders public tournament fields and races', (
    tester,
  ) async {
    final viewModel = _TournamentDetailViewModel(detail: _detail());

    await tester.pumpWidget(
      MaterialApp(
        home: SpectatorTournamentDetailScreen(
          tournamentId: '12',
          viewModel: viewModel,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Summer Cup'), findsOneWidget);
    expect(find.text('Phu Tho'), findsOneWidget);
    expect(find.text('National race'), findsOneWidget);
    expect(find.text('Public rules'), findsOneWidget);
    expect(find.text('Qualifier'), findsOneWidget);
    expect(find.text('Hang 1: Cup'), findsOneWidget);
  });

  testWidgets('tournament detail race item opens race callback', (
    tester,
  ) async {
    SpectatorRaceItem? openedRace;
    final viewModel = _TournamentDetailViewModel(detail: _detail());

    await tester.pumpWidget(
      MaterialApp(
        home: SpectatorTournamentDetailScreen(
          tournamentId: '12',
          viewModel: viewModel,
          onRaceTap: (race) => openedRace = race,
        ),
      ),
    );
    await tester.pump();

    await tester.ensureVisible(find.text('Qualifier'));
    await tester.pump();
    await tester.tap(find.text('Qualifier'));
    await tester.pump();

    expect(openedRace?.id, '5');
    expect(openedRace?.tournamentId, '12');
  });

  testWidgets('tournament detail shows empty races state', (tester) async {
    final viewModel = _TournamentDetailViewModel(
      detail: _detail(races: const []),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: SpectatorTournamentDetailScreen(
          tournamentId: '12',
          viewModel: viewModel,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Chua co cuoc dua trong giai dau nay.'), findsOneWidget);
  });

  testWidgets('tournament detail shows error and retries', (tester) async {
    final viewModel = _TournamentDetailViewModel(
      detail: _detail(),
      failuresBeforeSuccess: 1,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: SpectatorTournamentDetailScreen(
          tournamentId: '12',
          viewModel: viewModel,
        ),
      ),
    );
    await tester.pump();

    expect(find.textContaining('Temporary failure'), findsOneWidget);
    expect(viewModel.loadCalls, 1);

    await tester.tap(find.text('Thu lai'));
    await tester.pump();

    expect(find.text('Summer Cup'), findsOneWidget);
    expect(viewModel.loadCalls, 2);
  });

  testWidgets('home hero opens tournament detail callback', (tester) async {
    SpectatorFeaturedEvent? openedEvent;
    final viewModel = _HomeViewModel(
      nextData: SpectatorHomeData(
        featuredEvent: SpectatorFeaturedEvent.fromJson(const {
          'id': 12,
          'name': 'Summer Cup',
          'provinceName': 'Phu Tho',
          'bannerUrl': '/uploads/tournaments/12.jpg',
          'startAt': '2026-07-15T09:00:00',
          'status': 'OPEN_REGISTRATION',
        }),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: SpectatorHomeScreen(
          viewModel: viewModel,
          onTournamentTap: (event) => openedEvent = event,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Xem chi tiet'));
    await tester.pump();

    expect(openedEvent?.id, '12');
  });
}

class _TournamentDetailViewModel extends SpectatorTournamentDetailViewModel {
  _TournamentDetailViewModel({
    required this.detail,
    this.failuresBeforeSuccess = 0,
  }) : super(tournamentId: detail.id);

  final SpectatorTournamentDetail detail;
  int failuresBeforeSuccess;
  int loadCalls = 0;

  @override
  Future<void> load() async {
    loadCalls++;
    if (failuresBeforeSuccess > 0) {
      failuresBeforeSuccess--;
      data = null;
      errorMessage = 'Temporary failure';
      isLoading = false;
      notifyListeners();
      return;
    }

    data = detail;
    errorMessage = null;
    isLoading = false;
    notifyListeners();
  }
}

class _HomeViewModel extends SpectatorHomeViewModel {
  _HomeViewModel({required SpectatorHomeData nextData}) : _nextData = nextData;

  final SpectatorHomeData _nextData;

  @override
  Future<void> load() async {
    data = _nextData;
    isLoading = false;
    errorMessage = null;
    notifyListeners();
  }
}

SpectatorTournamentDetail _detail({List<SpectatorRaceDetail>? races}) {
  return SpectatorTournamentDetail(
    id: '12',
    name: 'Summer Cup',
    description: 'National race',
    location: 'Phu Tho',
    bannerUrl: '/uploads/tournaments/12.jpg',
    status: 'OPEN_REGISTRATION',
    registrationOpenAt: DateTime(2026, 6, 1),
    registrationCloseAt: DateTime(2026, 6, 30),
    startAt: DateTime(2026, 7, 15),
    endAt: DateTime(2026, 7, 16),
    rules: 'Public rules',
    races:
        races ??
        [
          SpectatorRaceDetail(
            race: SpectatorRaceItem.fromJson(const {
              'id': 5,
              'tournamentId': 12,
              'tournamentName': 'Summer Cup',
              'name': 'Qualifier',
              'distance': '1200m',
              'venueName': 'Track A',
              'scheduledStartAt': '2026-07-15T09:00:00',
              'participantCount': 4,
              'maxParticipants': 12,
              'status': 'SCHEDULED',
            }),
            prizes: const [
              SpectatorRacePrize(rank: 1, amount: 1000000, itemName: 'Cup'),
            ],
          ),
        ],
  );
}
