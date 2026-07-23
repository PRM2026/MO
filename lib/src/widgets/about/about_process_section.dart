import 'package:flutter/material.dart';

import '../../constants/about_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';
import '../../models/about_content.dart';

class AboutProcessSection extends StatelessWidget {
  const AboutProcessSection({super.key, required this.steps});

  final List<AboutProcessStep> steps;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Quy trình hoạt động',
          textAlign: TextAlign.center,
          style: AppTypography.headlineSm(AboutColors.primary),
        ),
        const SizedBox(height: AppSpacing.xl),
        Padding(
          padding: const EdgeInsets.only(left: 32),
          child: Stack(
            children: [
              Positioned(
                left: 15,
                top: 16,
                bottom: 16,
                child: Container(
                  width: 2,
                  color: AboutColors.secondaryContainer.withValues(alpha: 0.4),
                ),
              ),
              Column(
                children: [
                  for (var i = 0; i < steps.length; i++) ...[
                    if (i > 0) const SizedBox(height: 48),
                    _ProcessStepItem(step: steps[i]),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProcessStepItem extends StatelessWidget {
  const _ProcessStepItem({required this.step});

  final AboutProcessStep step;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AboutColors.secondary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AboutColors.secondary.withValues(alpha: 0.25),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            '${step.step}',
            style: const TextStyle(
              color: AboutColors.onSecondary,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                step.title,
                style: AppTypography.headlineSm(
                  AboutColors.primary,
                ).copyWith(fontSize: 18),
              ),
              const SizedBox(height: 4),
              Text(
                step.description,
                style: AppTypography.bodySm(AboutColors.outline),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
