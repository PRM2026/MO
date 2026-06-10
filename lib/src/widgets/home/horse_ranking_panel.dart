import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';
import '../../models/horse_ranking.dart';

class HorseRankingPanel extends StatelessWidget {
  const HorseRankingPanel({super.key, required this.rankings});

  final List<HorseRanking> rankings;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            for (var i = 0; i < rankings.length; i++) ...[
              if (i > 0) const SizedBox(height: AppSpacing.sm),
              HorseRankingTile(ranking: rankings[i]),
            ],
          ],
        ),
      ),
    );
  }
}

class HorseRankingTile extends StatelessWidget {
  const HorseRankingTile({super.key, required this.ranking});

  final HorseRanking ranking;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              _RankAvatar(ranking: ranking),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ranking.name,
                      style: AppTypography.bodyMd(AppColors.onSurface)
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'Chủ sở hữu: ${ranking.owner}',
                      style: AppTypography.labelCaps(
                        AppColors.onSurfaceVariant,
                      ).copyWith(fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              _WinRateChip(label: ranking.winRateLabel),
            ],
          ),
        ),
      ),
    );
  }
}

class _RankAvatar extends StatelessWidget {
  const _RankAvatar({required this.ranking});

  final HorseRanking ranking;

  @override
  Widget build(BuildContext context) {
    if (ranking.isLeader) {
      return CircleAvatar(
        radius: 20,
        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
        child: const Icon(Icons.emoji_events, color: AppColors.primary),
      );
    }

    final Color bg;
    final Color fg;
    switch (ranking.rank) {
      case 2:
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF64748B);
      case 3:
        bg = const Color(0xFFFFEDD5);
        fg = const Color(0xFFC2410C);
      default:
        bg = AppColors.surfaceContainer;
        fg = AppColors.onSurfaceVariant;
    }

    return CircleAvatar(
      radius: 20,
      backgroundColor: bg,
      child: Text(
        '${ranking.rank}',
        style: AppTypography.labelCaps(fg),
      ),
    );
  }
}

class _WinRateChip extends StatelessWidget {
  const _WinRateChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          label,
          style: AppTypography.labelCaps(const Color(0xFF15803D))
              .copyWith(fontSize: 11),
        ),
      ),
    );
  }
}
