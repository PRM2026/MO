import 'package:flutter/foundation.dart';

import '../models/owner_dashboard_data.dart';
import '../repositories/owner_dashboard_repository.dart';

class OwnerDashboardViewModel extends ChangeNotifier {
  OwnerDashboardViewModel({OwnerDashboardRepository? repository})
      : _repository = repository ?? OwnerDashboardRepository();

  final OwnerDashboardRepository _repository;

  bool isLoading = false;
  OwnerDashboardData? data;

  Future<void> loadDashboard() async {
    isLoading = true;
    notifyListeners();

    try {
      data = await _repository.fetchDashboard();
    } catch (error) {
      if (kDebugMode) debugPrint('OwnerDashboardViewModel: $error');
      data = OwnerDashboardData.sample();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
