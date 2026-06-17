import 'package:flutter/foundation.dart';

import '../models/jockey_dashboard_data.dart';
import '../repositories/jockey_dashboard_repository.dart';

class JockeyDashboardViewModel extends ChangeNotifier {
  JockeyDashboardViewModel({JockeyDashboardRepository? repository})
    : _repository = repository ?? JockeyDashboardRepository();

  final JockeyDashboardRepository _repository;

  bool isLoading = false;
  String? errorMessage;
  JockeyDashboardData? data;

  Future<void> loadDashboard() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      data = await _repository.fetchDashboard();
    } catch (error) {
      if (kDebugMode) debugPrint('JockeyDashboardViewModel: $error');
      data = null;
      errorMessage = 'Khong the tai du lieu tong quan jockey.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
