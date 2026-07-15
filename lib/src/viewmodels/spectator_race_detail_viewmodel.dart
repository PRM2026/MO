import 'package:flutter/foundation.dart';

import '../models/spectator_models.dart';
import '../repositories/spectator_repository.dart';

class SpectatorRaceDetailViewModel extends ChangeNotifier {
  SpectatorRaceDetailViewModel({
    required this.raceId,
    this.tournamentId,
    SpectatorRepository? repository,
  }) : _repository = repository ?? SpectatorRepository();

  final String raceId;
  final String? tournamentId;
  final SpectatorRepository _repository;

  bool isLoading = false;
  String? errorMessage;
  SpectatorRaceDetail? data;

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      data = tournamentId == null || tournamentId!.trim().isEmpty
          ? await _findRaceFromAllTournaments()
          : await _findRaceFromTournament(tournamentId!);
      if (data == null) {
        throw StateError('Khong tim thay cuoc dua.');
      }
    } catch (error) {
      if (kDebugMode) debugPrint('SpectatorRaceDetailViewModel: $error');
      data = null;
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> retry() => load();

  Future<SpectatorRaceDetail?> _findRaceFromAllTournaments() async {
    final tournaments = await _repository.fetchTournaments();
    for (final tournament in tournaments) {
      final detail = await _findRaceFromTournament(tournament.id);
      if (detail != null) return detail;
    }
    return null;
  }

  Future<SpectatorRaceDetail?> _findRaceFromTournament(String id) async {
    final tournament = await _repository.fetchTournamentDetail(id);
    for (final race in tournament.races) {
      if (race.id == raceId) {
        final detail = SpectatorRaceDetail.fromTournamentRace(
          race,
          tournament: tournament,
        );
        final results = await _repository.fetchRaceResults(raceId);
        return SpectatorRaceDetail(
          race: detail.race,
          description: detail.description,
          rules: detail.rules,
          prizes: detail.prizes,
          results: results
              .map(SpectatorResultFinisher.fromJockeyResult)
              .toList(growable: false),
        );
      }
    }
    return null;
  }
}
