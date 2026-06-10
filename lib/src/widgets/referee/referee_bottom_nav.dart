import 'package:flutter/material.dart';

import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';

enum RefereeTab { overview, races, violations, history, wallet }

class RefereeBottomNav extends StatelessWidget {
  const RefereeBottomNav({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
  });

  final RefereeTab currentTab;
  final ValueChanged<RefereeTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: RefereeColors.surfaceContainer,
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
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

  final RefereeTab tab;
  final IconData icon;
  final String label;
}

const _items = [
  _NavItemData(RefereeTab.overview, Icons.dashboard_outlined, 'Tổng quan'),
  _NavItemData(RefereeTab.races, Icons.sports_score_outlined, 'Cuộc đua'),
  _NavItemData(RefereeTab.violations, Icons.report_problem_outlined, 'Vi phạm'),
  _NavItemData(RefereeTab.history, Icons.history, 'Lịch sử'),
  _NavItemData(RefereeTab.wallet, Icons.account_balance_wallet_outlined, 'Ví'),
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
    final color =
        selected ? RefereeColors.tertiary : RefereeColors.onSurfaceVariant;

    return Material(
      color: selected
          ? RefereeColors.tertiaryContainer
          : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 2),
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
      ),
    );
  }
}
