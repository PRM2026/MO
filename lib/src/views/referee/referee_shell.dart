import 'package:flutter/material.dart';

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
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: IndexedStack(
        index: _currentTab.index,
        children: [
          const RefereeDashboardScreen(),
          const RefereeAssignedRacesScreen(),
          const RefereeViolationsScreen(),
          const RefereeHistoryScreen(),
          const RefereeWalletScreen(),
        ],
      ),
      bottomNavigationBar: RefereeBottomNav(
        currentTab: _currentTab,
        onTabSelected: (tab) => setState(() => _currentTab = tab),
      ),
    );
  }
}
