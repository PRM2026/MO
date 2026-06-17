import 'package:flutter/foundation.dart';

import '../models/violation_record.dart';
import '../repositories/referee_violations_repository.dart';

class RefereeViolationsViewModel extends ChangeNotifier {
  RefereeViolationsViewModel({RefereeViolationsRepository? repository})
      : _repository = repository ?? const RefereeViolationsRepository();

  final RefereeViolationsRepository _repository;

  bool isLoading = false;
  bool isSubmitting = false;
  ViolationsPageData? data;

  String selectedHorse = '';
  String selectedViolationType = '';
  String evidenceUrl = '';
  String notes = '';

  Future<void> loadPage() async {
    isLoading = true;
    notifyListeners();

    try {
      data = await _repository.fetchPageData();
      _applyDefaults();
    } catch (error) {
      if (kDebugMode) debugPrint('RefereeViolationsViewModel: $error');
      data = ViolationsPageData.sample();
      _applyDefaults();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _applyDefaults() {
    final options = data?.options;
    if (options == null) return;
    if (options.horses.isNotEmpty) selectedHorse = options.horses.first;
    if (options.violationTypes.isNotEmpty) {
      selectedViolationType = options.violationTypes.first;
    }
  }

  void updateHorse(String? value) {
    if (value == null) return;
    selectedHorse = value;
    notifyListeners();
  }

  void updateViolationType(String? value) {
    if (value == null) return;
    selectedViolationType = value;
    notifyListeners();
  }

  void updateEvidenceUrl(String value) {
    evidenceUrl = value;
    notifyListeners();
  }

  void updateNotes(String value) {
    notes = value;
    notifyListeners();
  }

  // NOTE: Backend endpoint for referee violations does not yet exist.
  // This is a local mock until the BE implements /referee/races/{id}/violations.
  Future<bool> submitViolation() async {
    isSubmitting = true;
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 400));

    isSubmitting = false;
    notes = '';
    evidenceUrl = '';
    notifyListeners();
    return true;
  }
}
