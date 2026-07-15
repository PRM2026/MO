import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horse_racing/src/models/jockey_race_result_response.dart';
import 'package:horse_racing/src/models/owner_tournament_detail.dart';
import 'package:horse_racing/src/models/spectator_models.dart';
import 'package:horse_racing/src/models/tournament_list_item.dart';
import 'package:horse_racing/src/models/user_profile.dart';
import 'package:horse_racing/src/repositories/spectator_repository.dart';
import 'package:horse_racing/src/services/spectator_api_service.dart';
import 'package:horse_racing/src/viewmodels/spectator_races_viewmodel.dart';
import 'package:horse_racing/src/views/spectator/spectator_races_screen.dart';

void main() {
  testWidgets('races screen renders API races and opens race callback', (
    tester,
  ) async {
    SpectatorRaceItem? openedRace;
    final viewModel = SpectatorRacesViewModel(
      repository: _FakeSpectatorRepository(
        tournaments: [_tournament()],
        details: {'12': _detail()},
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: SpectatorRacesScreen(
          viewModel: viewModel,
          onRaceTap: (race) => openedRace = race,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Qualifier'), findsWidgets);
    expect(find.text('Chua co cuoc dua nao.'), findsNothing);

    await tester.tap(find.text('Xem chi tiet').last);
    await tester.pump();

    expect(openedRace?.id, '5');
  });

  testWidgets('races screen shows empty API state', (tester) async {
    final viewModel = SpectatorRacesViewModel(
      repository: _FakeSpectatorRepository(tournaments: const []),
    );

    await tester.pumpWidget(
      MaterialApp(home: SpectatorRacesScreen(viewModel: viewModel)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Chua co cuoc dua nao.'), findsOneWidget);
  });

  testWidgets('races screen shows error and retries', (tester) async {
    final repository = _FakeSpectatorRepository(
      failuresBeforeSuccess: 1,
      tournaments: [_tournament()],
      details: {'12': _detail()},
    );
    final viewModel = SpectatorRacesViewModel(repository: repository);

    await tester.pumpWidget(
      MaterialApp(home: SpectatorRacesScreen(viewModel: viewModel)),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Temporary failure'), findsOneWidget);
    expect(repository.tournamentCalls, 1);

    await tester.tap(find.text('Thu lai'));
    await tester.pumpAndSettle();

    expect(find.text('Qualifier'), findsWidgets);
    expect(repository.tournamentCalls, 2);
  });

  testWidgets('races screen filters finished races from API data', (
    tester,
  ) async {
    final viewModel = SpectatorRacesViewModel(
      repository: _FakeSpectatorRepository(
        tournaments: [_tournament()],
        details: {'12': _detail(includeFinished: true)},
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: SpectatorRacesScreen(viewModel: viewModel)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Qualifier'), findsWidgets);
    expect(find.text('Final'), findsNothing);

    await tester.tap(find.text('Da ket thuc'));
    await tester.pumpAndSettle();

    expect(find.text('Final'), findsWidgets);
  });
}

class _FakeSpectatorRepository extends SpectatorRepository {
  _FakeSpectatorRepository({
    this.tournaments = const [],
    this.details = const {},
    this.failuresBeforeSuccess = 0,
  }) : super();

  final List<TournamentListItem> tournaments;
  final Map<String, OwnerTournamentDetail> details;
  int failuresBeforeSuccess;
  int tournamentCalls = 0;

  @override
  Future<List<TournamentListItem>> fetchTournaments() async {
    tournamentCalls++;
    if (failuresBeforeSuccess > 0) {
      failuresBeforeSuccess--;
      throw const SpectatorApiException('Temporary failure');
    }
    return tournaments;
  }

  @override
  Future<OwnerTournamentDetail> fetchTournamentDetail(String id) async {
    final detail = details[id];
    if (detail == null) throw SpectatorApiException('Missing detail $id');
    return detail;
  }

  @override
  Future<List<JockeyRaceResultResponse>> fetchRaceResults(String raceId) async {
    return const [];
  }

  @override
  Future<List<SpectatorFeaturedHorse>> fetchHorseRankings() async {
    return const [];
  }

  @override
  Future<UserProfile> fetchCurrentUser() async {
    throw const SpectatorApiException('No user');
  }
}

TournamentListItem _tournament() {
  return TournamentListItem.fromJson(const {
    'id': 12,
    'name': 'Summer Cup',
    'provinceName': 'Phu Tho',
    'bannerUrl': '/uploads/tournaments/12.jpg',
    'startAt': '2026-07-15T09:00:00',
    'status': 'OPEN_REGISTRATION',
  });
}

OwnerTournamentDetail _detail({bool includeFinished = false}) {
  return OwnerTournamentDetail.fromJson({
    'id': 12,
    'name': 'Summer Cup',
    'location': 'Phu Tho',
    'bannerUrl': '/uploads/tournaments/12.jpg',
    'status': 'OPEN_REGISTRATION',
    'races': [
      _raceJson(id: 5, name: 'Qualifier', status: 'SCHEDULED'),
      if (includeFinished)
        _raceJson(id: 6, name: 'Final', status: 'RESULT_CONFIRMED'),
    ],
  });
}

Map<String, Object?> _raceJson({
  required int id,
  required String name,
  required String status,
}) {
  return {
    'id': id,
    'name': name,
    'distance': '1200m',
    'venueName': 'Track A',
    'scheduledStartAt': '2026-07-15T09:00:00',
    'participantCount': 4,
    'maxParticipants': 12,
    'status': status,
  };
}
