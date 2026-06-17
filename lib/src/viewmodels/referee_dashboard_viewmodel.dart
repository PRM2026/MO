import 'package:flutter/foundation.dart';

import '../models/referee_dashboard_data.dart';
import '../repositories/referee_repository.dart';

class RefereeDashboardViewModel extends ChangeNotifier {
  RefereeDashboardViewModel({RefereeRepository? repository})
      : _repository = repository ?? RefereeRepository();

  final RefereeRepository _repository;

  bool isLoading = false;
  RefereeDashboardData? data;

  Future<void> loadDashboard() async {
    isLoading = true;
    notifyListeners();

    try {
      data = await _repository.fetchDashboard();
    } catch (error) {
      if (kDebugMode) debugPrint('RefereeDashboardViewModel: $error');
      data = RefereeDashboardData.sample();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
