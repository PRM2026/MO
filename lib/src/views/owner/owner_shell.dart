import 'package:flutter/material.dart';

import '../../repositories/auth_repository.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/portal_more_sheet.dart';
import '../../widgets/owner/owner_bottom_nav.dart';
import 'owner_dashboard_screen.dart';
import 'owner_horses_screen.dart';
import 'owner_profile_screen.dart';
import 'owner_race_registrations_screen.dart';
import 'owner_tournaments_screen.dart';

class OwnerShell extends StatefulWidget {
  const OwnerShell({super.key});

  @override
  State<OwnerShell> createState() => _OwnerShellState();
}

class _OwnerShellState extends State<OwnerShell> {
  OwnerTab _currentTab = OwnerTab.home;

  void _selectTab(OwnerTab tab) {
    if (tab == OwnerTab.more) {
      _showMore();
      return;
    }
    setState(() => _currentTab = tab);
  }

  Future<void> _showMore() {
    return showPortalMoreSheet(
      context,
      portalName: 'Owner Portal',
      actions: [
        PortalMoreAction(
          icon: Icons.person_outline,
          label: 'Hồ sơ cá nhân',
          onTap: () => setState(() => _currentTab = OwnerTab.profile),
        ),
        PortalMoreAction(
          icon: Icons.groups_outlined,
          label: 'Quản lý Jockey',
          onTap: () => AppRoutes.openOwnerJockeyInvitations(context),
        ),
        PortalMoreAction(
          icon: Icons.account_balance_wallet_outlined,
          label: 'Ví & thanh toán',
          onTap: () => AppRoutes.openOwnerWallet(context),
        ),
        PortalMoreAction(
          icon: Icons.insights_outlined,
          label: 'Kết quả thi đấu',
          onTap: () => AppRoutes.openOwnerResults(context),
        ),
        PortalMoreAction(
          icon: Icons.notifications_outlined,
          label: 'Thông báo',
          onTap: () => AppRoutes.openOwnerNotifications(context),
        ),
        PortalMoreAction(
          icon: Icons.logout,
          label: 'Đăng xuất',
          destructive: true,
          onTap: () async {
            await AuthRepository().logout();
            if (mounted) AppRoutes.openAfterLogout(context);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: IndexedStack(
        index: _currentTab.index,
        children: [
          OwnerDashboardScreen(
            onProfileTap: () => _selectTab(OwnerTab.profile),
            onViewAllHorses: () => _selectTab(OwnerTab.horses),
            onViewTournament: () => _selectTab(OwnerTab.tournament),
            onViewInvitations: () =>
                AppRoutes.openOwnerJockeyInvitations(context),
            onViewAcceptedJockeys: () =>
                AppRoutes.openOwnerAcceptedJockeys(context),
          ),
          OwnerTournamentsScreen(
            key: ValueKey('owner_tournaments_tab'),
            onProfileTap: () => _selectTab(OwnerTab.profile),
          ),
          OwnerHorsesScreen(onProfileTap: () => _selectTab(OwnerTab.profile)),
          const OwnerRaceRegistrationsScreen(),
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
