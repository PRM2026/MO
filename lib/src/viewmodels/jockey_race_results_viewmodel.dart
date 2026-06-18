import 'package:flutter/foundation.dart';

import '../repositories/jockey_race_results_repository.dart';

class JockeyRaceResultsViewModel extends ChangeNotifier {
  JockeyRaceResultsViewModel({
    required this.raceId,
    this.tournamentId,
    JockeyRaceResultsRepository? repository,
  }) : _repository = repository ?? JockeyRaceResultsRepository();

  final String raceId;
  final String? tournamentId;
  final JockeyRaceResultsRepository _repository;

  bool isLoading = false;
  String? errorMessage;
  JockeyRaceResultsData? data;

  bool get shouldLoadChallenge =>
      tournamentId != null && tournamentId!.trim().isNotEmpty;

  Future<void> loadResults() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      data = await _repository.fetchResults(
        raceId: raceId,
        tournamentId: tournamentId,
      );
    } catch (error) {
      if (kDebugMode) debugPrint('JockeyRaceResultsViewModel: $error');
      data = null;
      errorMessage = 'Không thể tải kết quả cuộc đua.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
