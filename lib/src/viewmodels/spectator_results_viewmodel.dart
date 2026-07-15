import 'package:flutter/foundation.dart';

import '../models/spectator_models.dart';
import '../repositories/spectator_repository.dart';

class SpectatorResultsViewModel extends ChangeNotifier {
  SpectatorResultsViewModel({SpectatorRepository? repository})
    : _repository = repository ?? SpectatorRepository();

  final SpectatorRepository _repository;

  bool isLoading = false;
  String? errorMessage;
  List<SpectatorResultGroup> _groups = const [];

  List<SpectatorResultGroup> get groups => _groups;

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final tournaments = await _repository.fetchTournaments();
      final loaded = <SpectatorResultGroup>[];

      for (final tournament in tournaments) {
        final detail = await _repository.fetchTournamentDetail(tournament.id);
        for (final race in detail.races) {
          final raceItem = SpectatorRaceItem.fromTournamentRace(
            race,
            tournament: detail,
          );
          if (raceItem.isUpcoming) continue;

          final results = await _repository.fetchRaceResults(race.id);
          if (results.isEmpty) continue;
          loaded.add(
            SpectatorResultGroup.fromRaceResults(
              race: raceItem,
              results: results,
              verified: raceItem.statusCode == 'RESULT_CONFIRMED',
            ),
          );
        }
      }

      _groups = loaded;
    } catch (error) {
      if (kDebugMode) debugPrint('SpectatorResultsViewModel: $error');
      _groups = const [];
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> retry() => load();
}
