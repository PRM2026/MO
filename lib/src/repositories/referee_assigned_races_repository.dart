import '../models/assigned_race_item.dart';

class RefereeAssignedRacesRepository {
  const RefereeAssignedRacesRepository();

  Future<AssignedRacesData> fetchAssignedRaces() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return AssignedRacesData.sample();
  }
}
