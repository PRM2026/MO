import 'package:flutter/foundation.dart';

import '../models/violation_record.dart';
import '../repositories/referee_violations_repository.dart';

class RefereeViolationsViewModel extends ChangeNotifier {
  RefereeViolationsViewModel({RefereeViolationsRepository? repository})
    : _repository = repository ?? RefereeViolationsRepository();

  final RefereeViolationsRepository _repository;

  bool isLoading = false;
  String? errorMessage;
  ViolationsPageData? data;

  Future<void> loadPage() async {
    isLoading = true;
    errorMessage = null;
    data = null;
    notifyListeners();

    try {
      data = await _repository.fetchPageData();
    } catch (error) {
      if (kDebugMode) debugPrint('RefereeViolationsViewModel: $error');
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
