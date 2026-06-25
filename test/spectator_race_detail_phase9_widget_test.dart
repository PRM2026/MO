import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horse_racing/src/models/spectator_models.dart';
import 'package:horse_racing/src/viewmodels/spectator_race_detail_viewmodel.dart';
import 'package:horse_racing/src/views/spectator/spectator_race_detail_screen.dart';

void main() {
  testWidgets('race detail renders race fields and no-result state', (
    tester,
  ) async {
    final viewModel = _RaceDetailViewModel(
      detail: SpectatorRaceDetail(
        race: _race(),
        prizes: const [
          SpectatorRacePrize(rank: 1, amount: 1000000, itemName: 'Cup'),
        ],
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: SpectatorRaceDetailScreen(
          raceId: '5',
          tournamentId: '12',
          viewModel: viewModel,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Qualifier'), findsOneWidget);
    expect(find.text('Summer Cup'), findsOneWidget);
    expect(find.text('1200m'), findsOneWidget);
    expect(find.text('Chua co ket qua'), findsOneWidget);
    expect(find.text('Chua co ket qua.'), findsOneWidget);
  });

  testWidgets('race detail enables results action when results exist', (
    tester,
  ) async {
    final viewModel = _RaceDetailViewModel(
      detail: SpectatorRaceDetail(
        race: _race(),
        results: const [
          SpectatorResultFinisher(
            rank: 1,
            horseId: 8,
            horseName: 'Night Wind',
            jockeyId: 9,
            jockeyName: 'jockey01',
            ownerId: 4,
            ownerUsername: 'owner01',
            time: '1:08.123',
            status: 'FINISHED',
          ),
        ],
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: SpectatorRaceDetailScreen(raceId: '5', viewModel: viewModel),
      ),
    );
    await tester.pump();

    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Xem ket qua'),
    );
    expect(button.onPressed, isNotNull);
  });

  testWidgets('race detail shows error and retries', (tester) async {
    final viewModel = _RaceDetailViewModel(
      detail: SpectatorRaceDetail(race: _race()),
      failuresBeforeSuccess: 1,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: SpectatorRaceDetailScreen(raceId: '5', viewModel: viewModel),
      ),
    );
    await tester.pump();

    expect(find.textContaining('Temporary failure'), findsOneWidget);
    expect(viewModel.loadCalls, 1);

    await tester.tap(find.text('Thu lai'));
    await tester.pump();

    expect(find.text('Qualifier'), findsOneWidget);
    expect(viewModel.loadCalls, 2);
  });
}

class _RaceDetailViewModel extends SpectatorRaceDetailViewModel {
  _RaceDetailViewModel({required this.detail, this.failuresBeforeSuccess = 0})
    : super(raceId: detail.race.id, tournamentId: detail.race.tournamentId);

  final SpectatorRaceDetail detail;
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

SpectatorRaceItem _race() {
  return SpectatorRaceItem.fromJson(const {
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
  });
}
