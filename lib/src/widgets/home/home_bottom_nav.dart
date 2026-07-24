import 'dart:ui';

import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';

enum HomeTab { home, tournaments, news, account, about }

class HomeBottomNav extends StatelessWidget {
  const HomeBottomNav({
    super.key,
    required this.currentTab,
    required this.isLoggedIn,
    required this.onTabSelected,
  });

  final HomeTab currentTab;
  final bool isLoggedIn;
  final ValueChanged<HomeTab> onTabSelected;

  static const _guestItems = [
    (HomeTab.home, Icons.home_outlined, Icons.home, 'Trang chủ'),
    (
      HomeTab.tournaments,
      Icons.emoji_events_outlined,
      Icons.emoji_events,
      AppConstants.tournamentsTabLabel,
    ),
    (HomeTab.news, Icons.newspaper_outlined, Icons.newspaper, 'Tin tức'),
    (HomeTab.about, Icons.info_outline, Icons.info, 'Giới thiệu'),
  ];

  static const _authItems = [
    (HomeTab.home, Icons.home_outlined, Icons.home, 'Trang chủ'),
    (
      HomeTab.tournaments,
      Icons.emoji_events_outlined,
      Icons.emoji_events,
      AppConstants.tournamentsTabLabel,
    ),
    (HomeTab.news, Icons.newspaper_outlined, Icons.newspaper, 'Tin tức'),
    (HomeTab.account, Icons.person_outline, Icons.person, 'Tài khoản'),
    (HomeTab.about, Icons.info_outline, Icons.info, 'Giới thiệu'),
  ];

  List<(HomeTab, IconData, IconData, String)> get _visibleItems =>
      isLoggedIn ? _authItems : _guestItems;

  int _indexForTab(HomeTab tab) {
    final index = _visibleItems.indexWhere((item) => item.$1 == tab);
    if (index >= 0) return index;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final items = _visibleItems;
    final selectedIndex = _indexForTab(currentTab);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: NavigationBar(
          height: 72,
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) => onTabSelected(items[index].$1),
          backgroundColor: AppColors.surface.withValues(alpha: 0.92),
          indicatorColor: AppColors.primary.withValues(alpha: 0.12),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            for (final item in items)
              NavigationDestination(
                icon: Icon(item.$2, size: 22),
                selectedIcon: Icon(item.$3, size: 22, color: AppColors.primary),
                label: item.$4,
              ),
          ],
        ),
      ),
    );
  }
}
