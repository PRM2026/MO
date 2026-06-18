import 'package:flutter_test/flutter_test.dart';
import 'package:horse_racing/src/models/auth_session.dart';
import 'package:horse_racing/src/models/jockey_race_result_response.dart';
import 'package:horse_racing/src/repositories/jockey_race_results_repository.dart';
import 'package:horse_racing/src/services/auth_storage.dart';
import 'package:horse_racing/src/services/jockey_race_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'does not request challenge standings without a tournament id',
    () async {
      final service = _CountingRaceService();
      final repository = JockeyRaceResultsRepository(
        service: service,
        storage: await _storageWithUserId(5),
      );

      final data = await repository.fetchResults(raceId: '22');

      expect(service.resultCalls, 1);
      expect(service.challengeCalls, 0);
      expect(data.currentUserId, 5);
      expect(data.isCurrentJockey(5), isTrue);
    },
  );

  test('requests challenge standings when tournament id exists', () async {
    final service = _CountingRaceService();
    final repository = JockeyRaceResultsRepository(
      service: service,
      storage: await _storageWithUserId(5),
    );

    final data = await repository.fetchResults(raceId: '22', tournamentId: '7');

    expect(service.challengeCalls, 1);
    expect(data.challengeStandings, hasLength(1));
  });
}

class _CountingRaceService extends JockeyRaceService {
  int resultCalls = 0;
  int challengeCalls = 0;

  @override
  Future<List<JockeyRaceResultResponse>> getRaceResults(String raceId) async {
    resultCalls++;
    return const [];
  }

  @override
  Future<List<JockeyChallengeStandingResponse>> getJockeyChallengeStandings(
    String tournamentId,
  ) async {
    challengeCalls++;
    return const [
      JockeyChallengeStandingResponse(
        jockeyId: 5,
        jockeyUsername: 'jockey01',
        totalPoints: 28,
        firstPlaces: 2,
        secondPlaces: 1,
        thirdPlaces: 0,
        challengeRank: 1,
        prizeAmount: 12000000,
        payoutStatus: 'PENDING',
      ),
    ];
  }
}

Future<AuthStorage> _storageWithUserId(int userId) async {
  SharedPreferences.setMockInitialValues({});
  final preferences = await SharedPreferences.getInstance();
  final storage = AuthStorage(preferences: preferences);
  await storage.saveSession(
    AuthSession(
      token: 'jockey-token',
      tokenType: 'Bearer',
      userId: userId,
      role: 'JOCKEY',
    ),
  );
  return storage;
}
