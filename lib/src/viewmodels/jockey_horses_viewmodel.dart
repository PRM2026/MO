import 'package:flutter/foundation.dart';

import '../models/jockey_horse_data.dart';
import '../repositories/jockey_horses_repository.dart';

class JockeyHorsesViewModel extends ChangeNotifier {
  JockeyHorsesViewModel({JockeyHorsesRepository? repository})
      : _repository = repository ?? const JockeyHorsesRepository();

  final JockeyHorsesRepository _repository;

  bool isLoading = false;
  JockeyHorsesData? data;

  Future<void> loadHorses() async {
    isLoading = true;
    notifyListeners();

    try {
      data = await _repository.fetchHorses();
    } catch (error) {
      if (kDebugMode) debugPrint('JockeyHorsesViewModel: $error');
      data = JockeyHorsesData.sample();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
