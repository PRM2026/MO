import 'package:flutter/foundation.dart';

import '../models/jockey_results_data.dart';
import '../repositories/jockey_results_repository.dart';

class JockeyResultsViewModel extends ChangeNotifier {
  JockeyResultsViewModel({JockeyResultsRepository? repository})
      : _repository = repository ?? const JockeyResultsRepository();

  final JockeyResultsRepository _repository;

  bool isLoading = false;
  JockeyResultsData? data;

  Future<void> loadResults() async {
    isLoading = true;
    notifyListeners();

    try {
      data = await _repository.fetchResults();
    } catch (error) {
      if (kDebugMode) debugPrint('JockeyResultsViewModel: $error');
      data = JockeyResultsData.sample();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
