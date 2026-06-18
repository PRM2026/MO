import '../models/jockey_race_response.dart';
import '../services/jockey_race_service.dart';

class JockeyRaceNotFoundException implements Exception {
  const JockeyRaceNotFoundException(this.raceId);

  final String raceId;

  @override
  String toString() => 'Race $raceId was not found in the jockey schedule.';
}

class JockeyRaceDetailRepository {
  JockeyRaceDetailRepository({JockeyRaceService? service})
    : _service = service ?? JockeyRaceService();

  final JockeyRaceService _service;

  Future<JockeyRaceResponse> fetchRace(String raceId) async {
    final races = await _service.getJockeyRaces();
    for (final race in races) {
      if (race.id == raceId) return race;
    }
    throw JockeyRaceNotFoundException(raceId);
  }
}
