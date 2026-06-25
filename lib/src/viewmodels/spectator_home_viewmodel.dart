import 'package:flutter/foundation.dart';

import '../models/spectator_models.dart';
import '../models/tournament_list_item.dart';
import '../repositories/spectator_repository.dart';

class SpectatorHomeViewModel extends ChangeNotifier {
  SpectatorHomeViewModel({SpectatorRepository? repository})
    : _repository = repository ?? SpectatorRepository();

  final SpectatorRepository _repository;

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

      var races = const <SpectatorRaceItem>[];
      if (featured != null && featured.id.isNotEmpty) {
        final detail = await _repository.fetchTournamentDetail(featured.id);
        races = detail.races
            .map((race) {
              return SpectatorRaceItem.fromTournamentRace(
                race,
                tournament: detail,
              );
            })
            .where((race) => race.isUpcoming)
            .take(3)
            .toList(growable: false);
      }

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

    final sorted = [...tournaments]
      ..sort((a, b) {
        final aDate = a.startAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.startAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return aDate.compareTo(bDate);
      });

    final picked = sorted.firstWhere(
      (item) =>
          item.status == 'OPEN_REGISTRATION' ||
          item.status == 'PUBLISHED' ||
          item.status == 'ONGOING',
      orElse: () => sorted.first,
    );

    return SpectatorFeaturedEvent.fromTournament(picked);
  }
}
