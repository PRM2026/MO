import '../models/jockey_race_result_response.dart';
import '../services/auth_storage.dart';
import '../services/jockey_race_service.dart';

class JockeyRaceResultsData {
  const JockeyRaceResultsData({
    required this.results,
    required this.challengeStandings,
    this.currentUserId,
  });

  final List<JockeyRaceResultResponse> results;
  final List<JockeyChallengeStandingResponse> challengeStandings;
  final int? currentUserId;

  bool isCurrentJockey(int jockeyId) => currentUserId == jockeyId;
}

class JockeyRaceResultsRepository {
  JockeyRaceResultsRepository({
    JockeyRaceService? service,
    AuthStorage? storage,
  }) : _service = service ?? JockeyRaceService(),
       _storage = storage ?? AuthStorage();

  final JockeyRaceService _service;
  final AuthStorage _storage;

  Future<JockeyRaceResultsData> fetchResults({
    required String raceId,
    String? tournamentId,
  }) async {
    final normalizedTournamentId = tournamentId?.trim();
    final futures = <Future<Object?>>[
      _service.getRaceResults(raceId),
      _storage.getUserId(),
      if (normalizedTournamentId != null && normalizedTournamentId.isNotEmpty)
        _service.getJockeyChallengeStandings(normalizedTournamentId),
    ];
    final values = await Future.wait(futures);

    return JockeyRaceResultsData(
      results: values[0] as List<JockeyRaceResultResponse>,
      currentUserId: values[1] as int?,
      challengeStandings: values.length > 2
          ? values[2] as List<JockeyChallengeStandingResponse>
          : const [],
    );
  }
}
