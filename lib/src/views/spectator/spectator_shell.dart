import 'package:flutter/material.dart';

import '../../models/spectator_models.dart';
import '../../repositories/auth_repository.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/portal_more_sheet.dart';
import '../../widgets/spectator/spectator_bottom_nav.dart';
import 'spectator_betting_screen.dart';
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
    if (tab == SpectatorTab.more) {
      _showMore();
      return;
    }
    setState(() => _currentTab = tab);
  }

  Future<void> _showMore() {
    return showPortalMoreSheet(
      context,
      portalName: 'Spectator Portal',
      actions: [
        PortalMoreAction(
          icon: Icons.emoji_events_outlined,
          label: 'Giải đấu',
          onTap: () => AppRoutes.openSpectatorTournaments(context),
        ),
        PortalMoreAction(
          icon: Icons.account_balance_wallet_outlined,
          label: 'Ví của tôi',
          onTap: () => AppRoutes.openSpectatorWallet(context),
        ),
        PortalMoreAction(
          icon: Icons.notifications_outlined,
          label: 'Thông báo',
          onTap: () => AppRoutes.openSpectatorNotifications(context),
        ),
        PortalMoreAction(
          icon: Icons.leaderboard_outlined,
          label: 'Xếp hạng ngựa',
          onTap: () => AppRoutes.openSpectatorHorseRanking(context),
        ),
        PortalMoreAction(
          icon: Icons.person_outline,
          label: 'Hồ sơ cá nhân',
          onTap: () => setState(() => _currentTab = SpectatorTab.profile),
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
      backgroundColor: Theme.of(context).colorScheme.surface,
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
          const SpectatorBettingScreen(),
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
