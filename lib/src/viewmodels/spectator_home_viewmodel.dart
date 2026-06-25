import 'package:flutter/foundation.dart';

import '../models/owner_tournament_detail.dart';
import '../models/spectator_models.dart';
import '../models/tournament_list_item.dart';
import '../repositories/spectator_repository.dart';

class SpectatorHomeViewModel extends ChangeNotifier {
  SpectatorHomeViewModel({
    SpectatorRepository? repository,
    DateTime Function()? now,
  }) : _repository = repository ?? SpectatorRepository(),
       _now = now ?? DateTime.now;

  final SpectatorRepository _repository;
  final DateTime Function() _now;

  bool isLoading = false;
  String? errorMessage;
  String? profileErrorMessage;
  SpectatorHomeData? data;

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    profileErrorMessage = null;
    notifyListeners();

    try {
      final tournaments = await _repository.fetchTournaments();
      final profile = await _tryFetchProfile();
      final featured = _resolveFeaturedTournament(tournaments);
      final details = await _fetchTournamentDetails(tournaments);
      final races = _resolveUpcomingRaces(details);

      data = SpectatorHomeData(
        featuredEvent: featured,
        profile: profile,
        scheduleHero: races.isEmpty
            ? null
            : SpectatorScheduleFeatured.fromRace(races.first),
        upcomingRaces: races,
      );
    } catch (error) {
      if (kDebugMode) debugPrint('SpectatorHomeViewModel: $error');
      data = null;
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> retry() => load();

  Future<List<OwnerTournamentDetail>> _fetchTournamentDetails(
    List<TournamentListItem> tournaments,
  ) async {
    final details = <OwnerTournamentDetail>[];
    for (final tournament in tournaments) {
      if (tournament.id.trim().isEmpty) continue;
      details.add(await _repository.fetchTournamentDetail(tournament.id));
    }
    return details;
  }

  List<SpectatorRaceItem> _resolveUpcomingRaces(
    List<OwnerTournamentDetail> details,
  ) {
    final races = <SpectatorRaceItem>[];
    for (final detail in details) {
      races.addAll(
        detail.races
            .map((race) {
              return SpectatorRaceItem.fromTournamentRace(
                race,
                tournament: detail,
              );
            })
            .where((race) => race.isUpcoming),
      );
    }

    races.sort((a, b) {
      final aDate = a.scheduledStartAt;
      final bDate = b.scheduledStartAt;
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return aDate.compareTo(bDate);
    });

    return races.take(3).toList(growable: false);
  }

  Future<SpectatorProfileData?> _tryFetchProfile() async {
    try {
      final user = await _repository.fetchCurrentUser();
      return SpectatorProfileData.fromUserProfile(user);
    } catch (error) {
      profileErrorMessage = error.toString();
      return null;
    }
  }

  SpectatorFeaturedEvent? _resolveFeaturedTournament(
    List<TournamentListItem> tournaments,
  ) {
    if (tournaments.isEmpty) return null;

    const priorityStatuses = ['OPEN_REGISTRATION', 'PUBLISHED', 'ONGOING'];

    for (final status in priorityStatuses) {
      final candidates = tournaments
          .where((item) => item.status == status)
          .toList(growable: false);
      if (candidates.isNotEmpty) {
        return SpectatorFeaturedEvent.fromTournament(
          _nearestByStartDate(candidates),
        );
      }
    }

    final future = tournaments
        .where((item) => _isFutureOrToday(item.startAt))
        .toList(growable: false);
    final picked = future.isNotEmpty
        ? _nearestByStartDate(future)
        : _nearestByStartDate(tournaments);

    return SpectatorFeaturedEvent.fromTournament(picked);
  }

  TournamentListItem _nearestByStartDate(List<TournamentListItem> items) {
    final sorted = [...items]
      ..sort((a, b) {
        final aDate = a.startAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.startAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return aDate.compareTo(bDate);
      });
    return sorted.first;
  }

  bool _isFutureOrToday(DateTime? date) {
    if (date == null) return false;
    final today = _dateOnly(_now());
    return !_dateOnly(date).isBefore(today);
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
