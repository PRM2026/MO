import '../models/jockey_schedule_data.dart';

class JockeyScheduleRepository {
  const JockeyScheduleRepository();

  Future<JockeyScheduleData> fetchSchedule() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return JockeyScheduleData.sample();
  }
}
