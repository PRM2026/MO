import 'package:flutter/foundation.dart';

import '../models/spectator_models.dart';
import '../repositories/spectator_repository.dart';

class SpectatorTournamentDetailViewModel extends ChangeNotifier {
  SpectatorTournamentDetailViewModel({
    required this.tournamentId,
    SpectatorRepository? repository,
  }) : _repository = repository ?? SpectatorRepository();

  final String tournamentId;
  final SpectatorRepository _repository;

  bool isLoading = false;
  String? errorMessage;
  SpectatorTournamentDetail? data;

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final detail = await _repository.fetchTournamentDetail(tournamentId);
      data = SpectatorTournamentDetail.fromOwnerDetail(detail);
    } catch (error) {
      if (kDebugMode) {
        debugPrint('SpectatorTournamentDetailViewModel: $error');
      }
      data = null;
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> retry() => load();
}
