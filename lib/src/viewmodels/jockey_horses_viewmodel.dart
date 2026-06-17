import 'package:flutter/foundation.dart';

import '../models/jockey_horse_data.dart';
import '../repositories/jockey_horses_repository.dart';

class JockeyHorsesViewModel extends ChangeNotifier {
  JockeyHorsesViewModel({JockeyHorsesRepository? repository})
    : _repository = repository ?? const JockeyHorsesRepository();

  final JockeyHorsesRepository _repository;

  bool isLoading = false;
  String? errorMessage;
  JockeyHorsesData? data;

  Future<void> loadHorses() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      data = await _repository.fetchHorses();
    } catch (error) {
      if (kDebugMode) debugPrint('JockeyHorsesViewModel: $error');
      data = null;
      errorMessage = 'Khong the tai danh sach ngua duoc phan cong.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
