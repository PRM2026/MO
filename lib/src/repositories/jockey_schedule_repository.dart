import '../models/jockey_schedule_data.dart';
import '../services/jockey_race_service.dart';

class JockeyScheduleRepository {
  JockeyScheduleRepository({JockeyRaceService? service})
    : _service = service ?? JockeyRaceService();

  final JockeyRaceService _service;

  Future<JockeyScheduleData> fetchSchedule() async {
    final races = await _service.getJockeyRaces();
    return JockeyScheduleData.fromResponses(races);
  }
}
