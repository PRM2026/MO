import 'package:flutter/material.dart';

import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../models/referee_dashboard_data.dart';
import 'referee_glass_card.dart';

class RefereeStatCard extends StatelessWidget {
  const RefereeStatCard({super.key, required this.stat});

  final RefereeStatItem stat;

  @override
  Widget build(BuildContext context) {
    return RefereeGlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(stat.icon, color: stat.iconColor, size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stat.label.toUpperCase(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.labelCaps(
                  RefereeColors.onSurfaceVariant,
                ).copyWith(fontWeight: FontWeight.w500, fontSize: 11),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Flexible(
                    child: Text(
                      stat.value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.headlineSm(
                        RefereeColors.onSurface,
                      ).copyWith(fontSize: 24, height: 1.1),
                    ),
                  ),
                  if (stat.suffix != null) ...[
                    const SizedBox(width: 4),
                    Text(
                      stat.suffix!,
                      style: AppTypography.labelCaps(
                        RefereeColors.onSurfaceVariant,
                      ).copyWith(fontWeight: FontWeight.w500, fontSize: 10),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
