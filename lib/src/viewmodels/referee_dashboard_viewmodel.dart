import 'package:flutter/foundation.dart';

import '../models/referee_dashboard_data.dart';
import '../repositories/referee_repository.dart';

class RefereeDashboardViewModel extends ChangeNotifier {
  RefereeDashboardViewModel({RefereeRepository? repository})
    : _repository = repository ?? RefereeRepository();

  final RefereeRepository _repository;

  bool isLoading = false;
  RefereeDashboardData? data;
  String? errorMessage;

  Future<void> loadDashboard() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      data = await _repository.fetchDashboard();
    } catch (error) {
      if (kDebugMode) debugPrint('RefereeDashboardViewModel: $error');
      errorMessage = _readableError(error);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String _readableError(Object error) {
    final message = error.toString().replaceFirst(
      RegExp(r'^.*Exception:\s*'),
      '',
    );
    if (message.trim().isNotEmpty) return message.trim();
    return 'Không thể tải dữ liệu tổng quan. Vui lòng thử lại.';
  }
}
