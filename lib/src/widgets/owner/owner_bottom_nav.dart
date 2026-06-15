import 'package:flutter/material.dart';

import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';

enum OwnerTab { home, tournament, horses, profile }

class OwnerBottomNav extends StatelessWidget {
  const OwnerBottomNav({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
  });

  final OwnerTab currentTab;
  final ValueChanged<OwnerTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: RefereeColors.portalSurface.withValues(alpha: 0.9),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            children: [
              for (final item in _items)
                Expanded(
                  child: _NavItem(
                    icon: item.icon,
                    selectedIcon: item.selectedIcon,
                    label: item.label,
                    selected: currentTab == item.tab,
                    onTap: () => onTabSelected(item.tab),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  const _NavItemData(
    this.tab,
    this.icon,
    this.selectedIcon,
    this.label,
  );

  final OwnerTab tab;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

const _items = [
  _NavItemData(
    OwnerTab.home,
    Icons.home_outlined,
    Icons.home,
    'Trang chủ',
  ),
  _NavItemData(
    OwnerTab.tournament,
    Icons.emoji_events_outlined,
    Icons.emoji_events,
    'Giải đấu',
  ),
  _NavItemData(
    OwnerTab.horses,
    Icons.art_track_outlined,
    Icons.art_track,
    'Ngựa',
  ),
  _NavItemData(
    OwnerTab.profile,
    Icons.person_outline,
    Icons.person,
    'Hồ sơ',
  ),
];

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? RefereeColors.championshipGold
        : RefereeColors.onSurfaceVariant.withValues(alpha: 0.7);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? selectedIcon : icon,
              color: color,
              size: selected ? 24 : 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.labelCaps(color).copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
