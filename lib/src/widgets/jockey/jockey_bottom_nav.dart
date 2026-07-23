import 'package:flutter/material.dart';

import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';

enum JockeyTab { dashboard, invitations, schedule, results, assignments, more }

class JockeyBottomNav extends StatelessWidget {
  const JockeyBottomNav({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
  });

  final JockeyTab currentTab;
  final ValueChanged<JockeyTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
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
  const _NavItemData(this.tab, this.icon, this.label);

  final JockeyTab tab;
  final IconData icon;
  final String label;
}

const _items = [
  _NavItemData(JockeyTab.dashboard, Icons.dashboard_outlined, 'Tổng quan'),
  _NavItemData(JockeyTab.invitations, Icons.mail_outline, 'Lời mời'),
  _NavItemData(JockeyTab.schedule, Icons.calendar_today_outlined, 'Lịch đua'),
  _NavItemData(JockeyTab.results, Icons.military_tech_outlined, 'Kết quả'),
  _NavItemData(JockeyTab.more, Icons.grid_view_outlined, 'Thêm'),
];

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = selected
        ? RefereeColors.championshipGold
        : scheme.onSurfaceVariant.withValues(alpha: 0.8);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: selected ? 24 : 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.labelCaps(
                color,
              ).copyWith(fontSize: 10, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
