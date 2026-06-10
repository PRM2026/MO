import '../models/jockey_horse_data.dart';

class JockeyHorsesRepository {
  const JockeyHorsesRepository();

  Future<JockeyHorsesData> fetchHorses() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return JockeyHorsesData.sample();
  }
}
