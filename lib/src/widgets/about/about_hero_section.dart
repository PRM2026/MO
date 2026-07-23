import 'package:flutter/material.dart';

import '../../constants/about_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';

class AboutHeroSection extends StatelessWidget {
  const AboutHeroSection({
    super.key,
    required this.badge,
    required this.title,
    required this.description,
  });

  final String badge;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AboutColors.secondaryContainer.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: AboutColors.secondary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.emoji_events_outlined,
                size: 16,
                color: AboutColors.secondary,
              ),
              const SizedBox(width: 8),
              Text(
                badge.toUpperCase(),
                style: AppTypography.labelCaps(
                  AboutColors.secondary,
                ).copyWith(fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTypography.displayMd(AboutColors.primary),
        ),
        const SizedBox(height: AppSpacing.sm),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: AppTypography.bodyMd(
              AboutColors.outline,
            ).copyWith(height: 1.6),
          ),
        ),
      ],
    );
  }
}
