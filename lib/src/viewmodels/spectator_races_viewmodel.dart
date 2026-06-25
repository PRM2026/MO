import 'package:flutter/foundation.dart';

import '../models/spectator_models.dart';
import '../repositories/spectator_repository.dart';

enum SpectatorRaceListFilter { upcoming, finished, date }

class SpectatorRacesViewModel extends ChangeNotifier {
  SpectatorRacesViewModel({SpectatorRepository? repository})
    : _repository = repository ?? SpectatorRepository();

  final SpectatorRepository _repository;

  bool isLoading = false;
  String? errorMessage;
  SpectatorRaceListFilter selectedFilter = SpectatorRaceListFilter.upcoming;
  DateTime? selectedDate;
  List<SpectatorRaceItem> _allRaces = const [];

  List<SpectatorRaceItem> get races {
    return _allRaces.where(_matchesFilter).toList(growable: false);
  }

  List<SpectatorRaceItem> get allRaces => _allRaces;

  SpectatorScheduleFeatured? get scheduleHero {
    if (_allRaces.isEmpty) return null;
    return SpectatorScheduleFeatured.fromRace(_allRaces.first);
  }

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final tournaments = await _repository.fetchTournaments();
      final loaded = <SpectatorRaceItem>[];

      for (final tournament in tournaments) {
        final detail = await _repository.fetchTournamentDetail(tournament.id);
        loaded.addAll(
          detail.races.map((race) {
            return SpectatorRaceItem.fromTournamentRace(
              race,
              tournament: detail,
            );
          }),
        );
      }

      loaded.sort((a, b) {
        final aDate =
            a.scheduledStartAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate =
            b.scheduledStartAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return aDate.compareTo(bDate);
      });
      _allRaces = loaded;
    } catch (error) {
      if (kDebugMode) debugPrint('SpectatorRacesViewModel: $error');
      _allRaces = const [];
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> retry() => load();

  void selectFilter(SpectatorRaceListFilter filter) {
    if (selectedFilter == filter) return;
    selectedFilter = filter;
    if (filter != SpectatorRaceListFilter.date) selectedDate = null;
    notifyListeners();
  }

  void selectDate(DateTime date) {
    selectedFilter = SpectatorRaceListFilter.date;
    selectedDate = DateTime(date.year, date.month, date.day);
    notifyListeners();
  }

  bool _matchesFilter(SpectatorRaceItem race) {
    return switch (selectedFilter) {
      SpectatorRaceListFilter.upcoming => race.isUpcoming,
      SpectatorRaceListFilter.finished => !race.isUpcoming,
      SpectatorRaceListFilter.date => _isSameDate(
        race.scheduledStartAt,
        selectedDate,
      ),
    };
  }

  bool _isSameDate(DateTime? left, DateTime? right) {
    if (left == null || right == null) return false;
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }
}
