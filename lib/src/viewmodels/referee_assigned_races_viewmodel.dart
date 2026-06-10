import 'package:flutter/foundation.dart';

import '../models/assigned_race_item.dart';
import '../repositories/referee_assigned_races_repository.dart';

class RefereeAssignedRacesViewModel extends ChangeNotifier {
  RefereeAssignedRacesViewModel({RefereeAssignedRacesRepository? repository})
      : _repository = repository ?? const RefereeAssignedRacesRepository();

  final RefereeAssignedRacesRepository _repository;

  bool isLoading = false;
  AssignedRacesData? _data;
  AssignedRaceFilter selectedFilter = AssignedRaceFilter.all;
  String searchQuery = '';

  AssignedRacesData? get data => _data;

  List<AssignedRaceItem> get filteredRaces {
    final items = _data?.races ?? [];
    final query = searchQuery.trim().toLowerCase();

    return items.where((race) {
      if (!race.matchesFilter(selectedFilter)) return false;
      if (query.isEmpty) return true;
      return race.title.toLowerCase().contains(query) ||
          race.raceCode.toLowerCase().contains(query) ||
          race.meta.location.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> loadRaces() async {
    isLoading = true;
    notifyListeners();

    try {
      _data = await _repository.fetchAssignedRaces();
    } catch (error) {
      if (kDebugMode) debugPrint('RefereeAssignedRacesViewModel: $error');
      _data = AssignedRacesData.sample();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void updateSearch(String value) {
    searchQuery = value;
    notifyListeners();
  }

  void updateFilter(AssignedRaceFilter filter) {
    selectedFilter = filter;
    notifyListeners();
  }
}
