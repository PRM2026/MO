import 'package:flutter/material.dart';

import '../../constants/referee_colors.dart';
import '../../models/jockey_dashboard_data.dart';
import '../../routes/app_routes.dart';
import '../../utils/app_toast.dart';
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

  void _handleQuickLink(JockeyDashboardQuickLink link) {
    switch (link.label.trim().toLowerCase()) {
      case 'invitations':
        setState(() => _currentTab = JockeyTab.invitations);
        return;
      case 'my races':
        setState(() => _currentTab = JockeyTab.schedule);
        return;
      case 'performance':
        setState(() => _currentTab = JockeyTab.results);
        return;
      case 'profile':
        AppRoutes.openJockeyProfile(context);
        return;
      case 'wallet':
      case 'notifications':
        AppToast.showSuccess(context, 'Chua ho tro trong phase nay');
        return;
      default:
        AppToast.showSuccess(context, 'Chua ho tro trong phase nay');
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RefereeColors.background,
      body: IndexedStack(
        index: _currentTab.index,
        children: [
          JockeyDashboardScreen(onQuickLinkSelected: _handleQuickLink),
          const JockeyInvitationsScreen(),
          const JockeyScheduleScreen(),
          const JockeyResultsScreen(),
          const JockeyHorsesScreen(),
        ],
      ),
      bottomNavigationBar: JockeyBottomNav(
        currentTab: _currentTab,
        onTabSelected: (tab) => setState(() => _currentTab = tab),
      ),
    );
  }
}
