import 'package:flutter/material.dart';

import '../routes/app_routes.dart';
import '../repositories/auth_repository.dart';
import '../utils/role_utils.dart';
import '../widgets/home/home_bottom_nav.dart';
import 'about_screen.dart';
import 'admin/admin_shell.dart';
import 'home_screen.dart';
import 'jockey/jockey_shell.dart';
import 'news_screen.dart';
import 'owner/owner_shell.dart';
import 'referee/referee_shell.dart';
import 'spectator/spectator_shell.dart';
import 'tournaments_screen.dart';
import 'user_account_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialTab = HomeTab.home});

  final HomeTab initialTab;

  static MainShellState? of(BuildContext context) {
    return context.findAncestorStateOfType<MainShellState>();
  }

  static void selectTab(BuildContext context, HomeTab tab) {
    of(context)?.selectTab(tab);
  }

  static void selectAccountSubTab(BuildContext context, AccountSubTab subTab) {
    of(context)?.selectAccountSubTab(subTab);
  }

  @override
  State<MainShell> createState() => MainShellState();
}

class MainShellState extends State<MainShell> {
  final AuthRepository _authRepository = AuthRepository();
  final GlobalKey<UserAccountScreenState> _accountScreenKey =
      GlobalKey<UserAccountScreenState>();

  late HomeTab _currentTab;
  bool _isLoggedIn = false;
  bool _isCheckingAuth = true;
  AccountSubTab _initialAccountSubTab = AccountSubTab.info;

  bool get isLoggedIn => _isLoggedIn;

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
    _refreshAuthState();
  }

  Future<void> _refreshAuthState() async {
    var loggedIn = await _authRepository.isLoggedIn();
    if (!mounted) return;

    String? portalRole;
    if (loggedIn) {
      final role = await _authRepository.resolveNavigationRole();
      loggedIn = await _authRepository.isLoggedIn();
      if (hasDedicatedPortal(role)) {
        portalRole = normalizePortalRole(role);
      }
    }

    if (!mounted) return;

    if (portalRole != null) {
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => switch (portalRole!) {
            'JOCKEY' => const JockeyShell(),
            'REFEREE' => const RefereeShell(),
            'OWNER' => const OwnerShell(),
            'SPECTATOR' => const SpectatorShell(),
            'ADMIN' => const AdminShell(),
            _ => const MainShell(),
          },
        ),
        (_) => false,
      );
      return;
    }

    setState(() {
      _isLoggedIn = loggedIn;
      _isCheckingAuth = false;
      if (!_isLoggedIn && _currentTab == HomeTab.account) {
        _currentTab = HomeTab.home;
      }
    });
  }

  Future<void> _redirectToPortalIfNeeded() async {
    if (!_isLoggedIn) return;

    final role = await _authRepository.resolveNavigationRole();
    if (!mounted || !hasDedicatedPortal(role)) return;

    AppRoutes.openDedicatedPortal(context, role);
  }

  Future<void> onLoggedIn({AccountSubTab subTab = AccountSubTab.info}) async {
    _initialAccountSubTab = subTab;
    await _refreshAuthState();
    if (!mounted) return;

    final role = await _authRepository.resolveNavigationRole();
    if (hasDedicatedPortal(role)) return;

    setState(() => _currentTab = HomeTab.account);
  }

  Future<void> onLoggedOut() async {
    await _refreshAuthState();
    if (!mounted) return;
    setState(() {
      if (_currentTab == HomeTab.account) {
        _currentTab = HomeTab.home;
      }
    });
  }

  void selectTab(HomeTab tab) {
    if (tab == HomeTab.account && !_isLoggedIn) {
      return;
    }
    if (tab == HomeTab.account && _isLoggedIn) {
      _redirectToPortalIfNeeded();
      return;
    }
    if (_currentTab == tab) return;
    setState(() => _currentTab = tab);
  }

  void selectAccountSubTab(AccountSubTab subTab) {
    _initialAccountSubTab = subTab;
    selectTab(HomeTab.account);
    _accountScreenKey.currentState?.selectSubTab(subTab);
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAuth) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      extendBody: false,
      body: IndexedStack(
        index: _currentTab.index,
        children: [
          const HomeScreen(),
          const TournamentsScreen(),
          const NewsScreen(),
          UserAccountScreen(
            key: _accountScreenKey,
            initialSubTab: _initialAccountSubTab,
          ),
          const AboutScreen(),
        ],
      ),
      bottomNavigationBar: HomeBottomNav(
        isLoggedIn: _isLoggedIn,
        currentTab: _currentTab,
        onTabSelected: selectTab,
      ),
    );
  }
}
