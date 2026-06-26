import 'package:flutter/material.dart';

import '../../constants/referee_colors.dart';
import '../../models/spectator_models.dart';
import '../../routes/app_routes.dart';
import '../../widgets/spectator/spectator_bottom_nav.dart';
import 'spectator_home_screen.dart';
import 'spectator_profile_screen.dart';
import 'spectator_races_screen.dart';
import 'spectator_results_screen.dart';

class SpectatorShell extends StatefulWidget {
  const SpectatorShell({super.key});

  @override
  State<SpectatorShell> createState() => _SpectatorShellState();
}

class _SpectatorShellState extends State<SpectatorShell> {
  SpectatorTab _currentTab = SpectatorTab.home;

  void _selectTab(SpectatorTab tab) {
    setState(() => _currentTab = tab);
  }

  void _openRaceDetail(SpectatorRaceItem race) {
    AppRoutes.openSpectatorRaceDetail(
      context,
      raceId: race.id,
      tournamentId: race.tournamentId,
    );
  }

  void _openLeaderboard(SpectatorResultGroup group) {
    AppRoutes.openSpectatorRaceResults(
      context,
      raceId: group.raceId,
      initialGroup: group,
    );
  }

  void _openTournamentDetail(SpectatorFeaturedEvent event) {
    AppRoutes.openSpectatorTournamentDetail(context, tournamentId: event.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RefereeColors.background,
      body: IndexedStack(
        index: _currentTab.index,
        children: [
          SpectatorHomeScreen(
            onProfileTap: () => _selectTab(SpectatorTab.profile),
            onRacesTap: () => _selectTab(SpectatorTab.races),
            onHorsesTap: () => AppRoutes.openSpectatorHorseRanking(context),
            onResultsTap: () => _selectTab(SpectatorTab.results),
            onViewAllRaces: () => _selectTab(SpectatorTab.races),
            onRaceTap: _openRaceDetail,
            onTournamentTap: _openTournamentDetail,
          ),
          SpectatorRacesScreen(
            onProfileTap: () => _selectTab(SpectatorTab.profile),
            onRaceTap: _openRaceDetail,
          ),
          SpectatorResultsScreen(
            onProfileTap: () => _selectTab(SpectatorTab.profile),
            onLeaderboardTap: _openLeaderboard,
          ),
          const SpectatorProfileScreen(),
        ],
      ),
      bottomNavigationBar: SpectatorBottomNav(
        currentTab: _currentTab,
        onTabSelected: _selectTab,
      ),
    );
  }
}
