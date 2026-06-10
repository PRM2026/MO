import 'package:flutter/material.dart';

import '../../constants/referee_colors.dart';
import '../../widgets/jockey/jockey_bottom_nav.dart';
import 'jockey_dashboard_screen.dart';
import 'jockey_horses_screen.dart';
import 'jockey_invitations_screen.dart';
import 'jockey_results_screen.dart';
import 'jockey_schedule_screen.dart';

class JockeyShell extends StatefulWidget {
  const JockeyShell({super.key});

  @override
  State<JockeyShell> createState() => _JockeyShellState();
}

class _JockeyShellState extends State<JockeyShell> {
  JockeyTab _currentTab = JockeyTab.dashboard;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RefereeColors.background,
      body: IndexedStack(
        index: _currentTab.index,
        children: const [
          JockeyDashboardScreen(),
          JockeyInvitationsScreen(),
          JockeyScheduleScreen(),
          JockeyResultsScreen(),
          JockeyHorsesScreen(),
        ],
      ),
      bottomNavigationBar: JockeyBottomNav(
        currentTab: _currentTab,
        onTabSelected: (tab) => setState(() => _currentTab = tab),
      ),
    );
  }
}
