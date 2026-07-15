import 'package:flutter/foundation.dart';

import '../models/spectator_models.dart';
import '../repositories/spectator_repository.dart';

class SpectatorHorseRankingViewModel extends ChangeNotifier {
  SpectatorHorseRankingViewModel({SpectatorRepository? repository})
    : _repository = repository ?? SpectatorRepository();

  final SpectatorRepository _repository;

  bool isLoading = false;
  String? errorMessage;
  List<SpectatorFeaturedHorse> horses = const [];

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final loaded = await _repository.fetchHorseRankings();
      horses = [...loaded]..sort((a, b) => a.rank.compareTo(b.rank));
    } catch (error) {
      if (kDebugMode) debugPrint('SpectatorHorseRankingViewModel: $error');
      horses = const [];
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> retry() => load();
}
