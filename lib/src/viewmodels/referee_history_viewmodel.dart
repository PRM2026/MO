import 'package:flutter/foundation.dart';

import '../models/race_result_confirmation.dart';
import '../repositories/referee_history_repository.dart';

class RefereeHistoryViewModel extends ChangeNotifier {
  RefereeHistoryViewModel({RefereeHistoryRepository? repository})
    : _repository = repository ?? RefereeHistoryRepository();

  final RefereeHistoryRepository _repository;

  bool isLoading = false;
  bool isConfirming = false;
  RaceResultConfirmationData? data;

  Future<void> loadData() async {
    isLoading = true;
    notifyListeners();

    try {
      data = await _repository.fetchPageData(raceId: data?.selectedRaceId);
    } catch (error) {
      if (kDebugMode) debugPrint('RefereeHistoryViewModel: $error');
      data = RaceResultConfirmationData.empty();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectRace(String raceId) async {
    isLoading = true;
    notifyListeners();

    try {
      data = await _repository.fetchRaceDetails(raceId);
    } catch (error) {
      if (kDebugMode) debugPrint('RefereeHistoryViewModel selectRace: $error');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> confirmResults() async {
    if (data?.canConfirm != true) return false;

    isConfirming = true;
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 400));

    isConfirming = false;
    notifyListeners();
    return false;
  }
}
