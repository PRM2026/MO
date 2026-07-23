import 'package:flutter/material.dart';

import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';

enum SpectatorTab { home, races, betting, results, profile, more }

class SpectatorBottomNav extends StatelessWidget {
  const SpectatorBottomNav({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
  });

  final SpectatorTab currentTab;
  final ValueChanged<SpectatorTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
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
  const _NavItemData(this.tab, this.icon, this.selectedIcon, this.label);

  final SpectatorTab tab;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

const _items = [
  _NavItemData(SpectatorTab.home, Icons.home_outlined, Icons.home, 'Trang chu'),
  _NavItemData(
    SpectatorTab.races,
    Icons.sports_score_outlined,
    Icons.sports_score,
    'Cuoc dua',
  ),
  _NavItemData(
    SpectatorTab.betting,
    Icons.paid_outlined,
    Icons.paid,
    'Đặt cược',
  ),
  _NavItemData(
    SpectatorTab.results,
    Icons.leaderboard_outlined,
    Icons.leaderboard,
    'Ket qua',
  ),
  _NavItemData(
    SpectatorTab.more,
    Icons.grid_view_outlined,
    Icons.grid_view,
    'Thêm',
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
    final scheme = Theme.of(context).colorScheme;
    final color = selected
        ? RefereeColors.championshipGold
        : scheme.onSurfaceVariant.withValues(alpha: 0.8);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          decoration: selected
              ? BoxDecoration(
                  color: scheme.primaryContainer.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(12),
                )
              : null,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(selected ? selectedIcon : icon, color: color, size: 22),
              const SizedBox(height: 2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelCaps(color).copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
