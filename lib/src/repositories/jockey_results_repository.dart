import '../models/jockey_results_data.dart';

class JockeyResultsRepository {
  const JockeyResultsRepository();

  Future<JockeyResultsData> fetchResults() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return JockeyResultsData.sample();
  }
}
