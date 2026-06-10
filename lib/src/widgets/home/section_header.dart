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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.headlineSm(AppColors.secondary),
          ),
        ),
        if (actionLabel != null) ...[
          const SizedBox(width: AppSpacing.sm),
          TextButton(
            onPressed: onActionTap,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    actionLabel!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelCaps(AppColors.primary),
                  ),
                ),
                const Icon(Icons.chevron_right, size: 18),
              ],
            ),
          ),
        ],
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
