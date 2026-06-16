import 'package:flutter/foundation.dart';

import '../models/owner_dashboard_data.dart';
import '../repositories/owner_dashboard_repository.dart';

class OwnerDashboardViewModel extends ChangeNotifier {
  OwnerDashboardViewModel({OwnerDashboardRepository? repository})
    : _repository = repository ?? OwnerDashboardRepository();

  final OwnerDashboardRepository _repository;

  bool isLoading = false;
  String? errorMessage;
  OwnerDashboardData? data;

  Future<void> loadDashboard() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      data = await _repository.fetchDashboard();
    } catch (error) {
      data = null;
      errorMessage = 'Không thể tải dữ liệu tổng quan.';
      if (kDebugMode) debugPrint('OwnerDashboardViewModel: $error');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshDashboard() => loadDashboard();
}
