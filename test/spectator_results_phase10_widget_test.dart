import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horse_racing/src/models/jockey_race_result_response.dart';
import 'package:horse_racing/src/models/owner_tournament_detail.dart';
import 'package:horse_racing/src/models/spectator_models.dart';
import 'package:horse_racing/src/models/tournament_list_item.dart';
import 'package:horse_racing/src/models/user_profile.dart';
import 'package:horse_racing/src/repositories/spectator_repository.dart';
import 'package:horse_racing/src/services/spectator_api_service.dart';
import 'package:horse_racing/src/viewmodels/spectator_results_viewmodel.dart';
import 'package:horse_racing/src/views/spectator/spectator_results_screen.dart';

void main() {
  testWidgets('results screen renders API result groups and only top 3', (
    tester,
  ) async {
    final viewModel = SpectatorResultsViewModel(
      repository: _FakeSpectatorRepository(
        tournaments: [_tournament()],
        details: {'12': _detail()},
        results: {
          '6': [
            _result(rank: 1, horseName: 'Night Wind'),
            _result(rank: 2, horseName: 'Silver Arrow'),
            _result(rank: 3, horseName: 'Morning Star'),
            _result(rank: 4, horseName: 'Hidden Fourth'),
          ],
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: SpectatorResultsScreen(viewModel: viewModel)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Final'), findsOneWidget);
    expect(find.text('Night Wind'), findsOneWidget);
    expect(find.text('Silver Arrow'), findsOneWidget);
    expect(find.text('Morning Star'), findsOneWidget);
    expect(find.text('Hidden Fourth'), findsNothing);
    expect(find.text('Xem chi tiet bang xep hang'), findsOneWidget);
  });

  testWidgets('results screen shows empty API state', (tester) async {
    final viewModel = SpectatorResultsViewModel(
      repository: _FakeSpectatorRepository(
        tournaments: [_tournament()],
        details: {'12': _detail()},
        results: const {'6': []},
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: SpectatorResultsScreen(viewModel: viewModel)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Chua co ket qua dua nao.'), findsOneWidget);
  });

  testWidgets('results screen shows error and retries', (tester) async {
    final repository = _FakeSpectatorRepository(
      failuresBeforeSuccess: 1,
      tournaments: [_tournament()],
      details: {'12': _detail()},
      results: {
        '6': [_result()],
      },
    );
    final viewModel = SpectatorResultsViewModel(repository: repository);

    await tester.pumpWidget(
      MaterialApp(home: SpectatorResultsScreen(viewModel: viewModel)),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Temporary failure'), findsOneWidget);
    expect(repository.tournamentCalls, 1);

    await tester.tap(find.text('Thu lai'));
    await tester.pumpAndSettle();

    expect(find.text('Final'), findsOneWidget);
    expect(repository.tournamentCalls, 2);
  });

  testWidgets('results screen filters verified groups', (tester) async {
    final viewModel = SpectatorResultsViewModel(
      repository: _FakeSpectatorRepository(
        tournaments: [_tournament()],
        details: {
          '12': _detail(
            races: [
              _raceJson(
                id: 6,
                name: 'Verified Final',
                status: 'RESULT_CONFIRMED',
              ),
              _raceJson(id: 7, name: 'Recent Final', status: 'COMPLETED'),
            ],
          ),
        },
        results: {
          '6': [_result()],
          '7': [_result(horseName: 'Recent Horse')],
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: SpectatorResultsScreen(viewModel: viewModel)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Verified Final'), findsOneWidget);
    expect(find.text('Recent Final'), findsOneWidget);

    await tester.tap(find.text('Da xac thuc'));
    await tester.pumpAndSettle();

    expect(find.text('Verified Final'), findsOneWidget);
    expect(find.text('Recent Final'), findsNothing);
  });
}

class _FakeSpectatorRepository extends SpectatorRepository {
  _FakeSpectatorRepository({
    this.tournaments = const [],
    this.details = const {},
    this.results = const {},
    this.failuresBeforeSuccess = 0,
  }) : super();

  final List<TournamentListItem> tournaments;
  final Map<String, OwnerTournamentDetail> details;
  final Map<String, List<JockeyRaceResultResponse>> results;
  int failuresBeforeSuccess;
  int tournamentCalls = 0;

  void _throwIfNeeded() {
    if (failuresBeforeSuccess > 0) {
      failuresBeforeSuccess--;
      throw const SpectatorApiException('Temporary failure');
    }
  }

  @override
  Future<List<TournamentListItem>> fetchTournaments() async {
    tournamentCalls++;
    _throwIfNeeded();
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
    return results[raceId] ?? const [];
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

OwnerTournamentDetail _detail({List<Map<String, Object?>>? races}) {
  return OwnerTournamentDetail.fromJson({
    'id': 12,
    'name': 'Summer Cup',
    'location': 'Phu Tho',
    'bannerUrl': '/uploads/tournaments/12.jpg',
    'status': 'OPEN_REGISTRATION',
    'races': races ?? [_raceJson(id: 6, name: 'Final')],
  });
}

Map<String, Object?> _raceJson({
  required int id,
  required String name,
  String status = 'RESULT_CONFIRMED',
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

JockeyRaceResultResponse _result({
  int rank = 1,
  String horseName = 'Night Wind',
}) {
  return JockeyRaceResultResponse.fromJson({
    'id': 30 + rank,
    'raceId': 6,
    'participantId': 22 + rank,
    'ownerId': 4,
    'ownerUsername': 'owner01',
    'horseId': 8 + rank,
    'horseName': horseName,
    'jockeyId': 9,
    'jockeyUsername': 'jockey01',
    'rank': rank,
    'finishTimeMillis': 68123 + rank,
    'status': 'FINISHED',
    'jockeyChallengePoints': 10,
    'jockeyPrizeAmount': 500000,
  });
}
