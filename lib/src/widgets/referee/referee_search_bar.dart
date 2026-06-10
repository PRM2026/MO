import 'package:flutter/material.dart';

import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../models/assigned_race_item.dart';

class RefereeSearchBar extends StatelessWidget {
  const RefereeSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: AppTypography.bodyMd(RefereeColors.onSurface),
      decoration: InputDecoration(
        hintText: 'Tìm tên giải đấu, trường đua...',
        hintStyle: AppTypography.bodyMd(
          RefereeColors.onSurfaceVariant.withValues(alpha: 0.8),
        ),
        prefixIcon: Icon(
          Icons.search,
          color: RefereeColors.onSurfaceVariant,
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: RefereeColors.tertiary),
        ),
      ),
    );
  }
}

class RefereeFilterChips extends StatelessWidget {
  const RefereeFilterChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final AssignedRaceFilter selected;
  final ValueChanged<AssignedRaceFilter> onSelected;

  static const _filters = [
    (AssignedRaceFilter.all, 'Tất cả'),
    (AssignedRaceFilter.upcoming, 'Sắp tới'),
    (AssignedRaceFilter.live, 'Đang diễn ra'),
    (AssignedRaceFilter.finished, 'Đã xong'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final item in _filters) ...[
            _FilterChip(
              label: item.$2,
              selected: selected == item.$1,
              onTap: () => onSelected(item.$1),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? RefereeColors.tertiary
          : Colors.white.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: selected
                ? null
                : Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Text(
            label,
            style: AppTypography.labelCaps(
              selected
                  ? const Color(0xFF261A00)
                  : RefereeColors.onSurfaceVariant,
            ).copyWith(fontSize: 13, letterSpacing: 0.3),
          ),
        ),
      ),
    );
  }
}
