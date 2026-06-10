import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';
import '../../models/stat_metric.dart';

class StatMetricCard extends StatelessWidget {
  const StatMetricCard({super.key, required this.metric});

  final StatMetric metric;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(metric.icon, size: 32, color: AppColors.primary),
            const SizedBox(height: AppSpacing.sm),
            Text(
              metric.value,
              style: AppTypography.displayMd(AppColors.onSurface),
            ),
            const SizedBox(height: 4),
            Text(
              metric.label,
              style: AppTypography.labelCaps(AppColors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class StatMetricsGrid extends StatelessWidget {
  const StatMetricsGrid({super.key, required this.metrics});

  final List<StatMetric> metrics;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: metrics.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.lg,
        mainAxisSpacing: AppSpacing.lg,
        childAspectRatio: 1.05,
      ),
      itemBuilder: (context, index) {
        return StatMetricCard(metric: metrics[index]);
      },
    );
  }
}
