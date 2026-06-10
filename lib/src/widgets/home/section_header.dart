import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onActionTap,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTypography.headlineSm(AppColors.secondary),
          ),
        ),
        if (actionLabel != null)
          TextButton.icon(
            onPressed: onActionTap,
            iconAlignment: IconAlignment.end,
            icon: const Icon(Icons.chevron_right, size: 18),
            label: Text(
              actionLabel!.toUpperCase(),
              style: AppTypography.labelCaps(AppColors.primary),
            ),
          ),
      ],
    );
  }
}

class HorizontalCarousel extends StatelessWidget {
  const HorizontalCarousel({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.height,
    this.itemSpacing = AppSpacing.lg,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double? height;
  final double itemSpacing;

  @override
  Widget build(BuildContext context) {
    final listView = ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.zero,
      itemCount: itemCount,
      separatorBuilder: (_, index) => SizedBox(width: itemSpacing),
      itemBuilder: itemBuilder,
    );

    if (height == null) return listView;
    return SizedBox(height: height, child: listView);
  }
}
