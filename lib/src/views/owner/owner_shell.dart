import 'package:flutter/material.dart';

import '../../constants/referee_colors.dart';
import '../../widgets/owner/owner_bottom_nav.dart';
import 'owner_dashboard_screen.dart';
import 'owner_horses_screen.dart';
import 'owner_profile_screen.dart';
import 'owner_tournaments_screen.dart';

class OwnerShell extends StatefulWidget {
  const OwnerShell({super.key});

  @override
  State<OwnerShell> createState() => _OwnerShellState();
}

class _OwnerShellState extends State<OwnerShell> {
  OwnerTab _currentTab = OwnerTab.home;

  void _selectTab(OwnerTab tab) {
    setState(() => _currentTab = tab);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RefereeColors.background,
      body: IndexedStack(
        index: _currentTab.index,
        children: [
          OwnerDashboardScreen(
            onProfileTap: () => _selectTab(OwnerTab.profile),
            onViewAllHorses: () => _selectTab(OwnerTab.horses),
            onViewTournament: () => _selectTab(OwnerTab.tournament),
          ),
          OwnerTournamentsScreen(
            key: ValueKey('owner_tournaments_tab'),
            onProfileTap: () => _selectTab(OwnerTab.profile),
          ),
          OwnerHorsesScreen(
            onProfileTap: () => _selectTab(OwnerTab.profile),
          ),
          const OwnerProfileScreen(),
        ],
      ),
      bottomNavigationBar: OwnerBottomNav(
        currentTab: _currentTab,
        onTabSelected: _selectTab,
      ),
    );
  }
}
