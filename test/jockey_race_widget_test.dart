import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horse_racing/src/models/jockey_race_response.dart';
import 'package:horse_racing/src/models/jockey_race_result_response.dart';
import 'package:horse_racing/src/repositories/jockey_race_detail_repository.dart';
import 'package:horse_racing/src/repositories/jockey_race_results_repository.dart';
import 'package:horse_racing/src/viewmodels/jockey_race_detail_viewmodel.dart';
import 'package:horse_racing/src/viewmodels/jockey_race_results_viewmodel.dart';
import 'package:horse_racing/src/views/jockey/jockey_race_detail_screen.dart';
import 'package:horse_racing/src/views/jockey/jockey_race_results_screen.dart';

void main() {
  testWidgets('race detail renders API fields, prizes, and results action', (
    tester,
  ) async {
    final viewModel = JockeyRaceDetailViewModel(
      raceId: '22',
      repository: _DetailRepository(_race()),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: JockeyRaceDetailScreen(raceId: '22', viewModel: viewModel),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Autumn Sprint'), findsOneWidget);
    expect(find.text('1600m'), findsOneWidget);
    expect(find.text('Saigon Track, District 7, HCMC'), findsOneWidget);
    expect(find.text('referee01'), findsOneWidget);
    expect(find.text('8 người (yêu cầu 4–12)'), findsOneWidget);
    expect(find.text('Bring racing license'), findsOneWidget);
    expect(find.text('Gold Cup • Champion'), findsOneWidget);
    expect(find.byKey(const Key('open-race-results')), findsOneWidget);
  });

  testWidgets('empty race results show the required empty message', (
    tester,
  ) async {
    final viewModel = JockeyRaceResultsViewModel(
      raceId: '22',
      repository: _ResultsRepository(
        const JockeyRaceResultsData(
          results: [],
          challengeStandings: [],
          currentUserId: 5,
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: JockeyRaceResultsScreen(raceId: '22', viewModel: viewModel),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Chưa có kết quả.'), findsOneWidget);
    expect(find.text('Xếp hạng Jockey Challenge'), findsNothing);
  });

  testWidgets('highlights current jockey in results and challenge standings', (
    tester,
  ) async {
    final viewModel = JockeyRaceResultsViewModel(
      raceId: '22',
      tournamentId: '7',
      repository: _ResultsRepository(
        JockeyRaceResultsData(
          results: [_result()],
          challengeStandings: [_standing()],
          currentUserId: 5,
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: JockeyRaceResultsScreen(
          raceId: '22',
          tournamentId: '7',
          viewModel: viewModel,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('current-jockey-result-5')), findsOneWidget);
    expect(find.byKey(const Key('current-jockey-challenge-5')), findsOneWidget);
    expect(find.text('Bạn'), findsNWidgets(2));
    expect(find.text('Silver Storm'), findsOneWidget);
    expect(find.text('1:13.450'), findsOneWidget);
    expect(find.text('10 điểm'), findsOneWidget);
    expect(find.text('Đã thanh toán'), findsOneWidget);
  });
}

class _DetailRepository extends JockeyRaceDetailRepository {
  _DetailRepository(this.race);

  final JockeyRaceResponse race;

  @override
  Future<JockeyRaceResponse> fetchRace(String raceId) async => race;
}

class _ResultsRepository extends JockeyRaceResultsRepository {
  _ResultsRepository(this.data);

  final JockeyRaceResultsData data;

  @override
  Future<JockeyRaceResultsData> fetchResults({
    required String raceId,
    String? tournamentId,
  }) async {
    return data;
  }
}

JockeyRaceResponse _race() {
  return JockeyRaceResponse(
    id: '22',
    tournamentId: '7',
    name: 'Autumn Sprint',
    distance: '1600m',
    minParticipants: 4,
    maxParticipants: 12,
    venueName: 'Saigon Track',
    venueAddress: 'District 7',
    provinceName: 'HCMC',
    scheduledStartAt: DateTime.parse('2026-06-18T08:00:00'),
    scheduledEndAt: DateTime.parse('2026-06-18T09:00:00'),
    refereeUsername: 'referee01',
    status: 'SCHEDULED',
    note: 'Bring racing license',
    prizes: [
      JockeyRacePrizeResponse(
        id: '1',
        rank: 1,
        amount: 50000000,
        itemName: 'Gold Cup',
        note: 'Champion',
        createdAt: DateTime.parse('2026-06-01T08:00:00'),
      ),
    ],
    participantCount: 8,
  );
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
