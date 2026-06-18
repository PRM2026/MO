import 'package:flutter/foundation.dart';

import '../models/jockey_results_data.dart';
import '../repositories/jockey_results_repository.dart';

class JockeyResultsViewModel extends ChangeNotifier {
  JockeyResultsViewModel({JockeyResultsRepository? repository})
    : _repository = repository ?? JockeyResultsRepository();

  final JockeyResultsRepository _repository;

  bool isLoading = false;
  String? errorMessage;
  JockeyResultsData? data;

  Future<void> loadResults() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      data = await _repository.fetchResults();
    } catch (error) {
      if (kDebugMode) debugPrint('JockeyResultsViewModel: $error');
      data = null;
      errorMessage = 'Khong the tai ket qua va thanh tich.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
