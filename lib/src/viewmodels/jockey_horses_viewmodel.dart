import 'package:flutter/foundation.dart';

import '../models/jockey_horse_data.dart';
import '../repositories/jockey_horses_repository.dart';

class JockeyHorsesViewModel extends ChangeNotifier {
  JockeyHorsesViewModel({JockeyHorsesRepository? repository})
    : _repository = repository ?? JockeyHorsesRepository();

  final JockeyHorsesRepository _repository;

  bool isLoading = false;
  String? errorMessage;
  JockeyHorseAssignmentsData? data;

  Future<void> loadAssignments() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      data = await _repository.fetchAssignments();
    } catch (error) {
      if (kDebugMode) debugPrint('JockeyHorsesViewModel: $error');
      data = null;
      errorMessage = 'Không thể tải danh sách ngựa được phân công.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
