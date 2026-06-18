import 'package:flutter_test/flutter_test.dart';
import 'package:horse_racing/src/models/jockey_race_result_response.dart';
import 'package:horse_racing/src/repositories/jockey_race_results_repository.dart';
import 'package:horse_racing/src/viewmodels/jockey_race_results_viewmodel.dart';

void main() {
  test('loads results and identifies the current jockey', () async {
    final repository = _FakeResultsRepository(
      data: JockeyRaceResultsData(
        results: [_result()],
        challengeStandings: [_standing()],
        currentUserId: 5,
      ),
    );
    final viewModel = JockeyRaceResultsViewModel(
      raceId: '22',
      tournamentId: '7',
      repository: repository,
    );

    await viewModel.loadResults();

    expect(viewModel.data?.results, hasLength(1));
    expect(viewModel.data?.isCurrentJockey(5), isTrue);
    expect(repository.lastTournamentId, '7');
  });

  test('passes no tournament id and accepts empty results', () async {
    final repository = _FakeResultsRepository(
      data: const JockeyRaceResultsData(results: [], challengeStandings: []),
    );
    final viewModel = JockeyRaceResultsViewModel(
      raceId: '22',
      repository: repository,
    );

    await viewModel.loadResults();

    expect(viewModel.shouldLoadChallenge, isFalse);
    expect(repository.lastTournamentId, isNull);
    expect(viewModel.data?.results, isEmpty);
  });

  test('retry clears an API error', () async {
    final repository = _RetryResultsRepository();
    final viewModel = JockeyRaceResultsViewModel(
      raceId: '22',
      repository: repository,
    );

    await viewModel.loadResults();
    expect(viewModel.errorMessage, 'Không thể tải kết quả cuộc đua.');

    await viewModel.loadResults();
    expect(viewModel.data?.results, hasLength(1));
    expect(repository.calls, 2);
  });
}

class _FakeResultsRepository extends JockeyRaceResultsRepository {
  _FakeResultsRepository({required this.data});

  final JockeyRaceResultsData data;
  String? lastTournamentId;

  @override
  Future<JockeyRaceResultsData> fetchResults({
    required String raceId,
    String? tournamentId,
  }) async {
    lastTournamentId = tournamentId;
    return data;
  }
}

class _RetryResultsRepository extends JockeyRaceResultsRepository {
  int calls = 0;

  @override
  Future<JockeyRaceResultsData> fetchResults({
    required String raceId,
    String? tournamentId,
  }) async {
    calls++;
    if (calls == 1) throw Exception('offline');
    return JockeyRaceResultsData(
      results: [_result()],
      challengeStandings: const [],
      currentUserId: 5,
    );
  }
}

JockeyRaceResultResponse _result() {
  return const JockeyRaceResultResponse(
    id: 91,
    raceId: 22,
    participantId: 31,
    ownerId: 4,
    ownerUsername: 'owner01',
    horseId: 8,
    horseName: 'Silver Storm',
    jockeyId: 5,
    jockeyUsername: 'jockey01',
    rank: 1,
    finishTimeMillis: 73450,
    status: 'FINISHED',
    jockeyChallengePoints: 10,
    jockeyPrizeAmount: 5000000,
    payoutStatus: 'PAID',
  );
}

JockeyChallengeStandingResponse _standing() {
  return const JockeyChallengeStandingResponse(
    jockeyId: 5,
    jockeyUsername: 'jockey01',
    totalPoints: 28,
    firstPlaces: 2,
    secondPlaces: 1,
    thirdPlaces: 0,
    challengeRank: 1,
    prizeAmount: 12000000,
    payoutStatus: 'PENDING',
  );
}
