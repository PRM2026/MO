import 'package:flutter/foundation.dart';

import '../models/jockey_schedule_data.dart';
import '../repositories/jockey_schedule_repository.dart';

class JockeyScheduleViewModel extends ChangeNotifier {
  JockeyScheduleViewModel({JockeyScheduleRepository? repository})
    : _repository = repository ?? JockeyScheduleRepository();

  final JockeyScheduleRepository _repository;

  bool isLoading = false;
  String? errorMessage;
  JockeyScheduleViewMode viewMode = JockeyScheduleViewMode.calendar;
  JockeyScheduleData? data;
  String? selectedDateKey;

  List<JockeyRaceScheduleItem> get visibleRaces {
    final races = data?.races ?? const [];
    if (viewMode == JockeyScheduleViewMode.list) {
      return races;
    }
    if (selectedDateKey == null) return const [];
    return races.where((race) => race.dateKey == selectedDateKey).toList();
  }

  Future<void> loadSchedule() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      data = await _repository.fetchSchedule();
      selectedDateKey = data?.dates
          .where((date) => date.isSelected)
          .map((date) => date.dateKey)
          .firstOrNull;
    } catch (error) {
      if (kDebugMode) debugPrint('JockeyScheduleViewModel: $error');
      data = null;
      selectedDateKey = null;
      errorMessage = 'Không thể tải lịch thi đấu.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setViewMode(JockeyScheduleViewMode mode) {
    if (viewMode == mode) return;
    viewMode = mode;
    notifyListeners();
  }

  void selectDate(String dateKey) {
    selectedDateKey = dateKey;
    notifyListeners();
  }
}
