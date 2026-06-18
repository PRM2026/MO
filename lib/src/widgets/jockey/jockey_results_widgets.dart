import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../models/jockey_results_data.dart';
import '../referee/referee_glass_card.dart';

class JockeyResultsStatsGrid extends StatelessWidget {
  const JockeyResultsStatsGrid({super.key, required this.stats});

  final List<JockeyResultsStatItem> stats;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 900
            ? 5
            : constraints.maxWidth >= 560
            ? 3
            : 2;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: crossAxisCount >= 3 ? 1.2 : 1.05,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) => _StatTile(stat: stats[index]),
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.stat});

  final JockeyResultsStatItem stat;

  @override
  Widget build(BuildContext context) {
    return RefereeGlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(stat.icon, color: stat.accentColor),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stat.label.toUpperCase(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.labelCaps(
                  RefereeColors.onSurfaceVariant,
                ).copyWith(fontSize: 10),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  stat.value,
                  style: AppTypography.headlineSm(
                    stat.highlightValue
                        ? RefereeColors.championshipGold
                        : RefereeColors.onSurface,
                  ).copyWith(fontSize: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class JockeyResultsHistorySection extends StatelessWidget {
  const JockeyResultsHistorySection({
    super.key,
    required this.results,
    required this.onResultTap,
  });

  final List<JockeyRaceResultItem> results;
  final ValueChanged<JockeyRaceResultItem> onResultTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeading(
          icon: Icons.flag_outlined,
          title: 'Lịch sử cuộc đua',
          subtitle: '${results.length} cuộc đua được phân công',
        ),
        const SizedBox(height: AppSpacing.md),
        for (var index = 0; index < results.length; index++) ...[
          _RaceResultCard(
            item: results[index],
            onTap: () => onResultTap(results[index]),
          ),
          if (index < results.length - 1) const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

class _RaceResultCard extends StatelessWidget {
  const _RaceResultCard({required this.item, required this.onTap});

  final JockeyRaceResultItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasResult = item.hasResult;

    return Semantics(
      button: true,
      child: InkWell(
        key: Key('jockey-result-${item.raceId}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: RefereeGlassCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.sm,
                children: [
                  SizedBox(
                    width: 560,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.eventName,
                          style: AppTypography.headlineSm(
                            RefereeColors.onSurface,
                          ).copyWith(fontSize: 19),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${item.scheduleLabel} • ${item.trackInfo}',
                          style: AppTypography.bodySm(
                            RefereeColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(label: item.rankLabel, color: item.rankColor),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth >= 700
                      ? (constraints.maxWidth - 3 * AppSpacing.md) / 4
                      : constraints.maxWidth >= 420
                      ? (constraints.maxWidth - AppSpacing.md) / 2
                      : constraints.maxWidth;
                  return Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.md,
                    children: [
                      _ResultMetric(
                        width: width,
                        label: 'Ngựa',
                        value: item.horseName,
                      ),
                      _ResultMetric(
                        width: width,
                        label: 'Thời gian',
                        value: item.finishTime,
                      ),
                      _ResultMetric(
                        width: width,
                        label: 'Điểm challenge',
                        value: item.challengePoints,
                      ),
                      _ResultMetric(
                        width: width,
                        label: 'Thưởng / payout',
                        value: hasResult
                            ? '${item.prizeAmount} • ${item.payoutStatus}'
                            : item.statusLabel,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.md),
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      hasResult ? 'Xem bảng kết quả' : 'Xem cuộc đua',
                      style: AppTypography.labelCaps(
                        RefereeColors.championshipGold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right,
                      color: RefereeColors.championshipGold,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultMetric extends StatelessWidget {
  const _ResultMetric({
    required this.width,
    required this.label,
    required this.value,
  });

  final double width;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTypography.labelCaps(
              RefereeColors.onSurfaceVariant,
            ).copyWith(fontSize: 10),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodyMd(RefereeColors.onSurface),
          ),
        ],
      ),
    );
  }
}

class JockeyPrizePayoutSection extends StatelessWidget {
  const JockeyPrizePayoutSection({super.key, required this.prizes});

  final List<JockeyPrizePayoutItem> prizes;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeading(
          icon: Icons.account_balance_wallet_outlined,
          title: 'Lịch sử thanh toán',
          subtitle: '${prizes.length} khoản thưởng và thù lao',
        ),
        const SizedBox(height: AppSpacing.md),
        RefereeGlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var index = 0; index < prizes.length; index++) ...[
                _PrizePayoutRow(item: prizes[index]),
                if (index < prizes.length - 1)
                  Divider(
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _PrizePayoutRow extends StatelessWidget {
  const _PrizePayoutRow({required this.item});

  final JockeyPrizePayoutItem item;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (item.statusCode) {
      'SUCCESS' => RefereeColors.successEmerald,
      'FAILED' => RefereeColors.statusRed,
      'PENDING' => RefereeColors.championshipGold,
      _ => RefereeColors.onSurfaceVariant,
    };

    return Padding(
      key: Key('jockey-prize-${item.id}'),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 600;
          final details = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.typeLabel,
                style: AppTypography.bodyMd(
                  RefereeColors.onSurface,
                ).copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                '${item.createdAtLabel} • ${item.directionLabel}',
                style: AppTypography.bodySm(RefereeColors.onSurfaceVariant),
              ),
              Text(
                item.referenceLabel,
                style: AppTypography.bodySm(RefereeColors.onSurfaceVariant),
              ),
              if (item.note?.trim().isNotEmpty == true) ...[
                const SizedBox(height: 4),
                Text(
                  item.note!.trim(),
                  style: AppTypography.bodySm(RefereeColors.onSurfaceVariant),
                ),
              ],
            ],
          );
          final amount = Column(
            crossAxisAlignment: compact
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.end,
            children: [
              Text(
                item.amountLabel,
                style: AppTypography.headlineSm(
                  RefereeColors.championshipGold,
                ).copyWith(fontSize: 18),
              ),
              const SizedBox(height: 6),
              _StatusBadge(label: item.statusLabel, color: statusColor),
            ],
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                details,
                const SizedBox(height: AppSpacing.md),
                amount,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: details),
              const SizedBox(width: AppSpacing.lg),
              amount,
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: RefereeColors.championshipGold),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.headlineSm(RefereeColors.onSurface),
              ),
              Text(
                subtitle,
                style: AppTypography.bodySm(RefereeColors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: AppTypography.labelCaps(color).copyWith(fontSize: 10),
      ),
    );
  }
}
