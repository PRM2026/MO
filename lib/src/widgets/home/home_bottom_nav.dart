import 'dart:ui';

import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

enum HomeTab { home, tournaments, news, about }

class HomeBottomNav extends StatelessWidget {
  const HomeBottomNav({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
  });

  final HomeTab currentTab;
  final ValueChanged<HomeTab> onTabSelected;

  static const _items = [
    (HomeTab.home, Icons.home_outlined, Icons.home, 'Trang chủ'),
    (HomeTab.tournaments, Icons.emoji_events_outlined, Icons.emoji_events,
        'Giải đấu'),
    (HomeTab.news, Icons.newspaper_outlined, Icons.newspaper, 'Tin tức'),
    (HomeTab.about, Icons.info_outline, Icons.info, 'Giới thiệu'),
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: NavigationBar(
          height: 72,
          selectedIndex: currentTab.index,
          onDestinationSelected: (index) =>
              onTabSelected(HomeTab.values[index]),
          backgroundColor: AppColors.surface.withValues(alpha: 0.92),
          indicatorColor: AppColors.primary.withValues(alpha: 0.12),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            for (final item in _items)
              NavigationDestination(
                icon: Icon(item.$2, size: 24),
                selectedIcon: Icon(
                  item.$3,
                  size: 24,
                  color: AppColors.primary,
                ),
                label: item.$4,
              ),
          ],
        ),
      ),
    );
  }
}
