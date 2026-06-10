import 'package:flutter/foundation.dart';

import '../models/jockey_schedule_data.dart';
import '../repositories/jockey_schedule_repository.dart';

class JockeyScheduleViewModel extends ChangeNotifier {
  JockeyScheduleViewModel({JockeyScheduleRepository? repository})
      : _repository = repository ?? const JockeyScheduleRepository();

  final JockeyScheduleRepository _repository;

  bool isLoading = false;
  JockeyScheduleViewMode viewMode = JockeyScheduleViewMode.calendar;
  JockeyScheduleData? data;
  String? selectedDateKey;

  List<JockeyRaceScheduleItem> get visibleRaces {
    final races = data?.races ?? const [];
    if (viewMode == JockeyScheduleViewMode.list || selectedDateKey == null) {
      return races;
    }
    return races.where((race) => race.dateKey == selectedDateKey).toList();
  }

  Future<void> loadSchedule() async {
    isLoading = true;
    notifyListeners();

    try {
      data = await _repository.fetchSchedule();
      selectedDateKey = data?.dates
          .where((date) => date.isSelected)
          .map((date) => date.dateKey)
          .firstOrNull;
    } catch (error) {
      if (kDebugMode) debugPrint('JockeyScheduleViewModel: $error');
      data = JockeyScheduleData.sample();
      selectedDateKey = '2024-12-15';
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

  Future<bool> confirmRace(String raceId) async {
    final races = data?.races;
    if (races == null) return false;

    final index = races.indexWhere((race) => race.id == raceId);
    if (index == -1) return false;

    await Future<void>.delayed(const Duration(milliseconds: 300));

    final current = races[index];
    data = JockeyScheduleData(
      dates: data!.dates,
      profileImageUrl: data!.profileImageUrl,
      races: [
        for (var i = 0; i < races.length; i++)
          if (i == index)
            JockeyRaceScheduleItem(
              id: current.id,
              dateKey: current.dateKey,
              timeLabel: current.timeLabel,
              eventName: current.eventName,
              horseName: current.horseName,
              venue: current.venue,
              laneLabel: current.laneLabel,
              status: JockeyRaceScheduleStatus.confirmed,
              imageUrl: current.imageUrl,
            )
          else
            races[i],
      ],
    );
    notifyListeners();
    return true;
  }
}
