import 'package:flutter/material.dart';

import '../../constants/about_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';
import '../../models/about_content.dart';

class AboutBenefitsSection extends StatelessWidget {
  const AboutBenefitsSection({super.key, required this.benefits});

  final List<AboutBenefit> benefits;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48),
      color: AboutColors.surfaceLow,
      child: Column(
        children: [
          Text('Lợi ích', style: AppTypography.headlineSm(AboutColors.primary)),
          const SizedBox(height: 4),
          Text(
            'Những giá trị mà hệ thống mang lại cho người dùng',
            style: AppTypography.bodySm(AboutColors.outline),
          ),
          const SizedBox(height: AppSpacing.xl),
          for (var i = 0; i < benefits.length; i++) ...[
            if (i > 0) const SizedBox(height: 48),
            _BenefitItem(benefit: benefits[i]),
          ],
        ],
      ),
    );
  }
}

class _BenefitItem extends StatelessWidget {
  const _BenefitItem({required this.benefit});

  final AboutBenefit benefit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AboutColors.surfaceHighest,
            shape: BoxShape.circle,
          ),
          child: Icon(benefit.icon, size: 32, color: AboutColors.secondary),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          benefit.title,
          style: AppTypography.headlineSm(AboutColors.primary),
        ),
        const SizedBox(height: AppSpacing.sm),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280),
          child: Text(
            benefit.description,
            textAlign: TextAlign.center,
            style: AppTypography.bodyMd(AboutColors.outline),
          ),
        ),
      ],
    );
  }
}
