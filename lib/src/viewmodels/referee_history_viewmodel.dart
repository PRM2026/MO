import 'package:flutter/foundation.dart';

import '../models/race_result_confirmation.dart';
import '../repositories/referee_history_repository.dart';

class RefereeHistoryViewModel extends ChangeNotifier {
  RefereeHistoryViewModel({RefereeHistoryRepository? repository})
      : _repository = repository ?? const RefereeHistoryRepository();

  final RefereeHistoryRepository _repository;

  bool isLoading = false;
  bool isConfirming = false;
  RaceResultConfirmationData? data;

  Future<void> loadData() async {
    isLoading = true;
    notifyListeners();

    try {
      data = await _repository.fetchResultConfirmation();
    } catch (error) {
      if (kDebugMode) debugPrint('RefereeHistoryViewModel: $error');
      data = RaceResultConfirmationData.sample();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> confirmResults() async {
    isConfirming = true;
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 500));

    isConfirming = false;
    notifyListeners();
    return true;
  }
}
