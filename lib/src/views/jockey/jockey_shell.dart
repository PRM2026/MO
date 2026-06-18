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
    switch (_quickLinkKey(link)) {
      case 'invitations':
        setState(() => _currentTab = JockeyTab.invitations);
        return;
      case 'schedule':
        setState(() => _currentTab = JockeyTab.schedule);
        return;
      case 'results':
        setState(() => _currentTab = JockeyTab.results);
        return;
      case 'assignments':
        setState(() => _currentTab = JockeyTab.assignments);
        return;
      case 'profile':
        AppRoutes.openJockeyProfile(context);
        return;
      case 'wallet':
        AppRoutes.openJockeyWallet(context);
        return;
      case 'notifications':
        AppRoutes.openJockeyNotifications(context);
        return;
      default:
        AppToast.showSuccess(context, 'Chua ho tro lien ket nay');
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

String _quickLinkKey(JockeyDashboardQuickLink link) {
  final route = _normalizeQuickLinkValue(link.route);
  final label = _normalizeQuickLinkValue(link.label);
  final combined = '$route $label';

  if (combined.contains('notification')) return 'notifications';
  if (combined.contains('wallet')) return 'wallet';
  if (combined.contains('profile')) return 'profile';
  if (combined.contains('invitation')) return 'invitations';
  if (combined.contains('assignment') ||
      combined.contains('horse') ||
      combined.contains('horses')) {
    return 'assignments';
  }
  if (combined.contains('result') || combined.contains('performance')) {
    return 'results';
  }
  if (combined.contains('schedule') ||
      combined.contains('race') ||
      combined.contains('races') ||
      combined.contains('my races')) {
    return 'schedule';
  }

  return label;
}

String _normalizeQuickLinkValue(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[_/-]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ');
}
