import 'package:flutter/foundation.dart';

import '../models/spectator_models.dart';
import '../repositories/spectator_repository.dart';

class SpectatorRaceResultsViewModel extends ChangeNotifier {
  SpectatorRaceResultsViewModel({
    required this.raceId,
    this.race,
    SpectatorRepository? repository,
  }) : _repository = repository ?? SpectatorRepository();

  final String raceId;
  final SpectatorRaceItem? race;
  final SpectatorRepository _repository;

  bool isLoading = false;
  String? errorMessage;
  SpectatorResultGroup? data;

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final results = await _repository.fetchRaceResults(raceId);
      final raceItem = race ?? SpectatorRaceItem.fromJson({'id': raceId});
      data = SpectatorResultGroup.fromRaceResults(
        race: raceItem,
        results: results,
      );
    } catch (error) {
      if (kDebugMode) debugPrint('SpectatorRaceResultsViewModel: $error');
      data = null;
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> retry() => load();
}
