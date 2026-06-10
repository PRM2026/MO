import 'package:flutter/material.dart';

import '../../constants/referee_colors.dart';
import '../../widgets/referee/referee_bottom_nav.dart';
import 'referee_assigned_races_screen.dart';
import 'referee_dashboard_screen.dart';
import 'referee_history_screen.dart';
import 'referee_violations_screen.dart';
import 'referee_wallet_screen.dart';

class RefereeShell extends StatefulWidget {
  const RefereeShell({super.key});

  @override
  State<RefereeShell> createState() => _RefereeShellState();
}

class _RefereeShellState extends State<RefereeShell> {
  RefereeTab _currentTab = RefereeTab.overview;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RefereeColors.background,
      body: IndexedStack(
        index: _currentTab.index,
        children: const [
          RefereeDashboardScreen(),
          RefereeAssignedRacesScreen(),
          RefereeViolationsScreen(),
          RefereeHistoryScreen(),
          RefereeWalletScreen(),
        ],
      ),
      bottomNavigationBar: RefereeBottomNav(
        currentTab: _currentTab,
        onTabSelected: (tab) => setState(() => _currentTab = tab),
      ),
    );
  }
}
