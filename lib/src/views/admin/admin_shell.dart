import 'package:flutter/material.dart';

import '../../repositories/auth_repository.dart';
import '../../routes/app_routes.dart';
import '../../widgets/admin/admin_ui.dart';
import '../../widgets/common/brand_logo.dart';
import '../../widgets/common/theme_mode_toggle.dart';
import 'admin_bet_markets_screen.dart';
import 'admin_dashboard_screen.dart';
import 'admin_horses_screen.dart';
import 'admin_judges_screen.dart';
import 'admin_news_screen.dart';
import 'admin_settings_screen.dart';
import 'admin_tournaments_screen.dart';
import 'admin_users_screen.dart';
import 'admin_wallet_screen.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  static const _destinations = [
    _AdminDestination('Tổng quan', Icons.dashboard_rounded),
    _AdminDestination('Giải đấu', Icons.emoji_events_rounded),
    _AdminDestination('Phân công trọng tài', Icons.gavel_rounded),
    _AdminDestination('Tin tức', Icons.newspaper_rounded),
    _AdminDestination('Người dùng', Icons.groups_rounded),
    _AdminDestination('Ngựa', Icons.pets_rounded),
    _AdminDestination('Ví hệ thống', Icons.account_balance_wallet_rounded),
    _AdminDestination('Cài đặt', Icons.settings_rounded),
    _AdminDestination('Cấu hình cược', Icons.percent_rounded),
  ];

  final AuthRepository _auth = AuthRepository();
  int _index = 0;
  String _displayName = 'Admin';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await _auth.loadProfile();
    if (!mounted) return;
    setState(
      () => _displayName = profile.fullName?.trim().isNotEmpty == true
          ? profile.fullName!
          : 'Admin',
    );
  }

  List<Widget> get _screens => const [
    AdminDashboardScreen(),
    AdminTournamentsScreen(),
    AdminJudgesScreen(),
    AdminNewsScreen(),
    AdminUsersScreen(),
    AdminHorsesScreen(),
    AdminWalletScreen(),
    AdminSettingsScreen(),
    AdminBetMarketsScreen(),
  ];

  void _select(int index) {
    setState(() => _index = index);
    if (Navigator.of(context).canPop()) Navigator.of(context).pop();
  }

  Future<void> _logout() async {
    await _auth.logout();
    if (!mounted) return;
    AppRoutes.openAfterLogout(context);
  }

  Future<void> _showMore() async {
    final selected = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: AdminPalette.navyLight,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AdminPalette.muted,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 14),
              for (final index in [2, 3, 5, 7, 8])
                ListTile(
                  leading: Icon(
                    _destinations[index].icon,
                    color: _index == index
                        ? AdminPalette.gold
                        : AdminPalette.muted,
                  ),
                  title: Text(
                    _destinations[index].label,
                    style: TextStyle(
                      color: _index == index
                          ? AdminPalette.goldLight
                          : Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: AdminPalette.muted,
                  ),
                  onTap: () => Navigator.pop(context, index),
                ),
            ],
          ),
        ),
      ),
    );
    if (selected != null) setState(() => _index = selected);
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = Theme.of(context);
    final isDark = appTheme.brightness == Brightness.dark;
    final adminScheme = isDark
        ? const ColorScheme.dark(
            primary: AdminPalette.gold,
            secondary: AdminPalette.goldLight,
            surface: AdminPalette.card,
            error: AdminPalette.danger,
          )
        : appTheme.colorScheme.copyWith(
            primary: AdminPalette.gold,
            secondary: AdminPalette.goldLight,
            error: AdminPalette.danger,
          );
    return Theme(
      data: appTheme.copyWith(
        scaffoldBackgroundColor: adminScheme.surface,
        colorScheme: adminScheme,
        chipTheme: Theme.of(context).chipTheme.copyWith(
          backgroundColor: AdminPalette.card,
          selectedColor: AdminPalette.gold,
          side: const BorderSide(color: AdminPalette.line),
          labelStyle: const TextStyle(color: Colors.white),
          secondaryLabelStyle: const TextStyle(
            color: AdminPalette.navy,
            fontWeight: FontWeight.w800,
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AdminPalette.line),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AdminPalette.gold),
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: adminScheme.surface,
        appBar: AppBar(
          backgroundColor: adminScheme.surface,
          surfaceTintColor: Colors.transparent,
          foregroundColor: adminScheme.onSurface,
          titleSpacing: 0,
          title: const Row(
            children: [
              BrandLogo(size: 34),
              SizedBox(width: 9),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Grand Championship',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                  Text(
                    'ADMIN PORTAL',
                    style: TextStyle(
                      color: AdminPalette.gold,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.3,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            const ThemeModeIconButton(color: AdminPalette.goldLight),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: CircleAvatar(
                radius: 17,
                backgroundColor: AdminPalette.gold,
                foregroundColor: AdminPalette.navy,
                child: Text(
                  _displayName.isEmpty
                      ? 'A'
                      : _displayName.characters.first.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
        drawer: Drawer(
          backgroundColor: AdminPalette.navyLight,
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: AdminPalette.gold,
                        foregroundColor: AdminPalette.navy,
                        child: Text(
                          _displayName.isEmpty
                              ? 'A'
                              : _displayName.characters.first.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _displayName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const Text(
                              'Quản trị viên hệ thống',
                              style: TextStyle(
                                color: AdminPalette.muted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: AdminPalette.line),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: _destinations.length,
                    itemBuilder: (_, index) {
                      final item = _destinations[index];
                      final selected = _index == index;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: ListTile(
                          selected: selected,
                          selectedTileColor: AdminPalette.gold.withValues(
                            alpha: .14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          leading: Icon(
                            item.icon,
                            color: selected
                                ? AdminPalette.gold
                                : AdminPalette.muted,
                          ),
                          title: Text(
                            item.label,
                            style: TextStyle(
                              color: selected
                                  ? AdminPalette.goldLight
                                  : Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          onTap: () => _select(index),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(color: AdminPalette.line),
                ListTile(
                  leading: const Icon(
                    Icons.logout_rounded,
                    color: AdminPalette.danger,
                  ),
                  title: const Text(
                    'Đăng xuất',
                    style: TextStyle(
                      color: AdminPalette.danger,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  onTap: _logout,
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
        body: IndexedStack(index: _index, children: _screens),
        bottomNavigationBar: NavigationBar(
          height: 72,
          backgroundColor: AdminPalette.navyLight,
          indicatorColor: AdminPalette.gold.withValues(alpha: .18),
          selectedIndex: switch (_index) {
            0 => 0,
            1 => 1,
            4 => 2,
            6 => 3,
            _ => 4,
          },
          onDestinationSelected: (index) {
            switch (index) {
              case 0:
                setState(() => _index = 0);
              case 1:
                setState(() => _index = 1);
              case 2:
                setState(() => _index = 4);
              case 3:
                setState(() => _index = 6);
              case 4:
                _showMore();
            }
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard_rounded),
              label: 'Tổng quan',
            ),
            NavigationDestination(
              icon: Icon(Icons.emoji_events_outlined),
              selectedIcon: Icon(Icons.emoji_events_rounded),
              label: 'Giải đấu',
            ),
            NavigationDestination(
              icon: Icon(Icons.groups_outlined),
              selectedIcon: Icon(Icons.groups_rounded),
              label: 'Người dùng',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined),
              selectedIcon: Icon(Icons.account_balance_wallet_rounded),
              label: 'Ví',
            ),
            NavigationDestination(
              icon: Icon(Icons.grid_view_rounded),
              label: 'Thêm',
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminDestination {
  const _AdminDestination(this.label, this.icon);

  final String label;
  final IconData icon;
}
