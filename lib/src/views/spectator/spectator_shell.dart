import 'package:flutter/material.dart';

import '../../constants/referee_colors.dart';
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
            onResultsTap: () => _selectTab(SpectatorTab.results),
            onViewAllRaces: () => _selectTab(SpectatorTab.races),
          ),
          SpectatorRacesScreen(
            onProfileTap: () => _selectTab(SpectatorTab.profile),
          ),
          SpectatorResultsScreen(
            onProfileTap: () => _selectTab(SpectatorTab.profile),
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
