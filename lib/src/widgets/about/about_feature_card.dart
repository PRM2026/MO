import 'package:flutter/material.dart';

import '../../constants/about_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';
import '../../models/about_content.dart';

class AboutFeatureCard extends StatelessWidget {
  const AboutFeatureCard({super.key, required this.feature});

  final AboutFeature feature;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AboutColors.outlineVariant),
      ),
      shadowColor: AboutColors.primary.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AboutColors.secondaryContainer.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(feature.icon, color: AboutColors.secondary),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    feature.title,
                    style: AppTypography.headlineSm(
                      AboutColors.primary,
                    ).copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    feature.description,
                    style: AppTypography.bodySm(AboutColors.outline),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AboutFeaturesSection extends StatelessWidget {
  const AboutFeaturesSection({super.key, required this.features});

  final List<AboutFeature> features;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Tính năng chính',
          textAlign: TextAlign.center,
          style: AppTypography.headlineSm(AboutColors.primary),
        ),
        const SizedBox(height: AppSpacing.lg),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: features.length,
          separatorBuilder: (context, index) =>
              const SizedBox(height: AppSpacing.lg),
          itemBuilder: (context, index) =>
              AboutFeatureCard(feature: features[index]),
        ),
      ],
    );
  }
}
