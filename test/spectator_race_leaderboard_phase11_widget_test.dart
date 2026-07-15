import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horse_racing/src/models/spectator_models.dart';
import 'package:horse_racing/src/viewmodels/spectator_race_detail_viewmodel.dart';
import 'package:horse_racing/src/viewmodels/spectator_race_results_viewmodel.dart';
import 'package:horse_racing/src/viewmodels/spectator_results_viewmodel.dart';
import 'package:horse_racing/src/views/spectator/spectator_race_detail_screen.dart';
import 'package:horse_racing/src/views/spectator/spectator_race_results_screen.dart';
import 'package:horse_racing/src/views/spectator/spectator_results_screen.dart';

void main() {
  testWidgets('leaderboard screen renders full result list', (tester) async {
    final viewModel = _RaceResultsViewModel(
      group: _group(
        finishers: [
          _finisher(rank: 1, horseName: 'Night Wind'),
          _finisher(rank: 2, horseName: 'Silver Arrow'),
          _finisher(rank: 3, horseName: 'Morning Star'),
          _finisher(rank: 4, horseName: 'Hidden Fourth'),
        ],
        verified: true,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: SpectatorRaceResultsScreen(raceId: '6', viewModel: viewModel),
      ),
    );
    await tester.pump();

    expect(find.text('Final'), findsOneWidget);
    expect(find.text('Da xac thuc'), findsOneWidget);
    expect(find.text('Night Wind'), findsOneWidget);
    expect(find.text('Silver Arrow'), findsOneWidget);
    expect(find.text('Morning Star'), findsOneWidget);
    expect(find.text('Hidden Fourth'), findsOneWidget);
    expect(find.text('Jockey: jockey01'), findsWidgets);
    expect(find.text('Owner: owner01'), findsWidgets);
    expect(find.text('Trang thai: FINISHED'), findsWidgets);
  });

  testWidgets('leaderboard screen shows empty state', (tester) async {
    final viewModel = _RaceResultsViewModel(group: _group(finishers: const []));

    await tester.pumpWidget(
      MaterialApp(
        home: SpectatorRaceResultsScreen(raceId: '6', viewModel: viewModel),
      ),
    );
    await tester.pump();

    expect(find.text('Chua co ket qua cho cuoc dua nay.'), findsOneWidget);
  });

  testWidgets('leaderboard screen shows error and retries', (tester) async {
    final viewModel = _RaceResultsViewModel(
      group: _group(finishers: [_finisher()]),
      failuresBeforeSuccess: 1,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: SpectatorRaceResultsScreen(raceId: '6', viewModel: viewModel),
      ),
    );
    await tester.pump();

    expect(find.textContaining('Temporary failure'), findsOneWidget);
    expect(viewModel.loadCalls, 1);

    await tester.tap(find.text('Thu lai'));
    await tester.pump();

    expect(find.text('Final'), findsOneWidget);
    expect(viewModel.loadCalls, 2);
  });

  testWidgets('results card opens leaderboard callback', (tester) async {
    SpectatorResultGroup? openedGroup;
    final viewModel = _ResultsViewModel(groups: [_group()]);

    await tester.pumpWidget(
      MaterialApp(
        home: SpectatorResultsScreen(
          viewModel: viewModel,
          onLeaderboardTap: (group) => openedGroup = group,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Xem chi tiet bang xep hang'));
    await tester.pump();

    expect(openedGroup?.raceId, '6');
  });

  testWidgets('race detail results action opens leaderboard callback', (
    tester,
  ) async {
    SpectatorRaceDetail? openedDetail;
    final viewModel = _RaceDetailViewModel(
      detail: SpectatorRaceDetail(race: _race(), results: [_finisher()]),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: SpectatorRaceDetailScreen(
          raceId: '6',
          viewModel: viewModel,
          onResultsTap: (detail) => openedDetail = detail,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Xem ket qua'));
    await tester.pump();

    expect(openedDetail?.race.id, '6');
  });
}

class _RaceResultsViewModel extends SpectatorRaceResultsViewModel {
  _RaceResultsViewModel({required this.group, this.failuresBeforeSuccess = 0})
    : super(raceId: group.raceId);

  final SpectatorResultGroup group;
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

    data = group;
    errorMessage = null;
    isLoading = false;
    notifyListeners();
  }
}

class _ResultsViewModel extends SpectatorResultsViewModel {
  _ResultsViewModel({required this.groups});

  @override
  final List<SpectatorResultGroup> groups;

  @override
  Future<void> load() async {
    isLoading = false;
    errorMessage = null;
    notifyListeners();
  }
}

class _RaceDetailViewModel extends SpectatorRaceDetailViewModel {
  _RaceDetailViewModel({required this.detail}) : super(raceId: detail.race.id);

  final SpectatorRaceDetail detail;

  @override
  Future<void> load() async {
    data = detail;
    errorMessage = null;
    isLoading = false;
    notifyListeners();
  }
}

SpectatorResultGroup _group({
  List<SpectatorResultFinisher>? finishers,
  bool verified = false,
}) {
  return SpectatorResultGroup(
    raceId: '6',
    title: 'Final',
    meta: '15/07/2026, 1200m, Track A',
    category: SpectatorResultCategory.recent,
    verified: verified,
    finishers: finishers ?? [_finisher()],
  );
}

SpectatorRaceItem _race() {
  return SpectatorRaceItem.fromJson(const {
    'id': 6,
    'tournamentId': 12,
    'tournamentName': 'Summer Cup',
    'name': 'Final',
    'distance': '1200m',
    'venueName': 'Track A',
    'scheduledStartAt': '2026-07-15T09:00:00',
    'participantCount': 4,
    'maxParticipants': 12,
    'status': 'RESULT_CONFIRMED',
  });
}

SpectatorResultFinisher _finisher({
  int rank = 1,
  String horseName = 'Night Wind',
}) {
  return SpectatorResultFinisher(
    rank: rank,
    horseId: 8 + rank,
    horseName: horseName,
    jockeyId: 9,
    jockeyName: 'jockey01',
    ownerId: 4,
    ownerUsername: 'owner01',
    time: '1:08.123',
    status: 'FINISHED',
  );
}
