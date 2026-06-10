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

  String selectedLane = 'Làn 01';
  String selectedHorse = 'H042 - Crimson Blaze';
  String selectedJockey = 'J-Văn Nam';
  String selectedViolationType = 'Lấn làn (Track Interference)';
  String penalty = '';
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
    selectedLane = options.lanes.first;
    selectedHorse = options.horses.first;
    selectedJockey = options.jockeys.first;
    selectedViolationType = options.violationTypes.first;
  }

  void updateLane(String? value) {
    if (value == null) return;
    selectedLane = value;
    notifyListeners();
  }

  void updateHorse(String? value) {
    if (value == null) return;
    selectedHorse = value;
    notifyListeners();
  }

  void updateJockey(String? value) {
    if (value == null) return;
    selectedJockey = value;
    notifyListeners();
  }

  void updateViolationType(String? value) {
    if (value == null) return;
    selectedViolationType = value;
    notifyListeners();
  }

  void updatePenalty(String value) {
    penalty = value;
    notifyListeners();
  }

  void updateNotes(String value) {
    notes = value;
    notifyListeners();
  }

  Future<bool> submitViolation() async {
    isSubmitting = true;
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 500));

    isSubmitting = false;
    notes = '';
    penalty = '';
    notifyListeners();
    return true;
  }
}
