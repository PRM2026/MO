import '../models/owner_dashboard_data.dart';
import '../models/owner_horse_item.dart';
import '../models/tournament_list_item.dart';
import '../repositories/auth_repository.dart';
import '../services/owner_dashboard_service.dart';
import '../services/owner_horse_service.dart';

class OwnerDashboardRepository {
  OwnerDashboardRepository({
    OwnerDashboardService? dashboardService,
    OwnerHorseService? horseService,
    AuthRepository? authRepository,
  }) : _dashboardService = dashboardService ?? OwnerDashboardService(),
       _horseService = horseService ?? OwnerHorseService(),
       _authRepository = authRepository ?? AuthRepository();

  final OwnerDashboardService _dashboardService;
  final OwnerHorseService _horseService;
  final AuthRepository _authRepository;

  Future<OwnerDashboardData> fetchDashboard() async {
    String? profileImageUrl;
    try {
      final user = await _authRepository.refreshCurrentUser();
      profileImageUrl = user.avatarUrl;
    } catch (_) {}

    final sample = OwnerDashboardData.sample(profileImageUrl: profileImageUrl);

    final dashboard = await _dashboardService.getOwnerDashboard();
    final tournaments = await _dashboardService.getTournaments();
    final horses = await _horseService.getOwnerHorses();

    final hero = _resolveHero(tournaments, sample.hero);
    final featured = _resolveFeaturedHorses(horses, sample.featuredHorses);
    final races = racesFromDashboard(dashboard);
    final upcoming = races.isNotEmpty ? races : sample.upcomingRaces;

    return OwnerDashboardData(
      hero: hero,
      featuredHorses: featured,
      upcomingRaces: upcoming,
      profileImageUrl: profileImageUrl ?? sample.profileImageUrl,
    );
  }

  OwnerHeroTournament _resolveHero(
    List<TournamentListItem> tournaments,
    OwnerHeroTournament fallback,
  ) {
    if (tournaments.isEmpty) return fallback;

    final sorted = [...tournaments]
      ..sort((a, b) {
        final aDate = a.startAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.startAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return aDate.compareTo(bDate);
      });

    final pick = sorted.firstWhere(
      (item) =>
          item.status == 'OPEN_REGISTRATION' ||
          item.status == 'PUBLISHED' ||
          item.status == 'ONGOING',
      orElse: () => sorted.first,
    );

    return heroFromTournament(pick);
  }

  List<OwnerFeaturedHorse> _resolveFeaturedHorses(
    List<OwnerHorseItem> horses,
    List<OwnerFeaturedHorse> fallback,
  ) {
    if (horses.isEmpty) return fallback;

    return horses
        .take(6)
        .map((horse) => horse.toFeatured())
        .toList(growable: false);
  }
}
