import 'package:flutter/material.dart';

import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../data/spectator_results_mock.dart';
import '../news/news_network_image.dart';
import 'spectator_glass_card.dart';

class SpectatorResultsHero extends StatelessWidget {
  const SpectatorResultsHero({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 192,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Opacity(
              opacity: 0.4,
              child: NewsNetworkImage(imageUrl: SpectatorResultsMock.heroImageUrl),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    RefereeColors.glassFill,
                    RefereeColors.glassFill.withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Kết Quả Đua Ngựa',
                    style: AppTypography.displayLg(
                      RefereeColors.championshipGold,
                    ).copyWith(fontSize: 32, height: 40 / 32),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Thống kê chi tiết các chặng đua gần nhất',
                    style: AppTypography.bodyMd(
                      RefereeColors.onSurfaceVariant,
                    ),
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

class SpectatorResultsFilterBar extends StatelessWidget {
  const SpectatorResultsFilterBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final SpectatorResultsFilter selected;
  final ValueChanged<SpectatorResultsFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final (filter, label) in SpectatorResultsMock.filters) ...[
            _FilterChip(
              label: label,
              selected: selected == filter,
              onTap: () => onSelected(filter),
            ),
            if (filter != SpectatorResultsFilter.speedChallenge)
              const SizedBox(width: 12),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? RefereeColors.championshipGold
                : RefereeColors.glassFill,
            border: selected
                ? null
                : Border.all(color: RefereeColors.glassBorder),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: AppTypography.bodySm(
              selected
                  ? const Color(0xFF101C2E)
                  : RefereeColors.onSurfaceVariant,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

class SpectatorRaceResultCard extends StatelessWidget {
  const SpectatorRaceResultCard({
    super.key,
    required this.group,
    this.onLeaderboardTap,
  });

  final SpectatorRaceResultGroup group;
  final VoidCallback? onLeaderboardTap;

  @override
  Widget build(BuildContext context) {
    final accentColor =
        group.accentColor ?? RefereeColors.championshipGold;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          SpectatorGlassCard(
            borderRadius: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              group.title,
                              style: AppTypography.headlineSm(Colors.white)
                                  .copyWith(fontSize: 24, height: 32 / 24),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              group.meta.toUpperCase(),
                              style: AppTypography.labelCaps(
                                RefereeColors.onSurfaceVariant,
                              ).copyWith(fontSize: 12, letterSpacing: 1.2),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        group.verified
                            ? Icons.verified_outlined
                            : Icons.event_available_outlined,
                        color: group.verified
                            ? RefereeColors.championshipGold
                            : RefereeColors.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      for (final finisher in group.finishers) ...[
                        _FinisherRow(finisher: finisher),
                        if (finisher != group.finishers.last)
                          const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
                if (group.showLeaderboardAction)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: OutlinedButton(
                      onPressed: onLeaderboardTap,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: RefereeColors.championshipGold,
                        side: BorderSide(
                          color: RefereeColors.championshipGold.withValues(
                            alpha: 0.2,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Xem chi tiết bảng xếp hạng',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 4,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _FinisherRow extends StatelessWidget {
  const _FinisherRow({required this.finisher});

  final SpectatorResultFinisher finisher;

  @override
  Widget build(BuildContext context) {
    final isFirst = finisher.rank == 1;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isFirst ? Colors.white.withValues(alpha: 0.05) : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _RankBadge(rank: finisher.rank, highlighted: isFirst),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  finisher.horseName,
                  style: AppTypography.bodySm(
                    isFirst ? Colors.white : RefereeColors.onSurface,
                  ).copyWith(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                Text(
                  'Jockey: ${finisher.jockeyName}',
                  style: AppTypography.bodySm(
                    RefereeColors.onSurfaceVariant,
                  ).copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                finisher.time,
                style: AppTypography.bodySm(
                  isFirst
                      ? RefereeColors.championshipGold
                      : RefereeColors.onSurface,
                ).copyWith(
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.14,
                ),
              ),
              if (finisher.delta != null)
                Text(
                  finisher.delta!,
                  style: AppTypography.bodySm(
                    finisher.isPersonalBest
                        ? RefereeColors.successEmerald
                        : RefereeColors.onSurfaceVariant,
                  ).copyWith(fontSize: 12),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank, required this.highlighted});

  final int rank;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: highlighted
            ? RefereeColors.championshipGold
            : Colors.transparent,
        border: highlighted
            ? null
            : Border.all(color: RefereeColors.outlineVariant),
      ),
      child: Text(
        '$rank',
        style: AppTypography.bodySm(
          highlighted
              ? RefereeColors.background
              : RefereeColors.onSurfaceVariant,
        ).copyWith(fontWeight: FontWeight.w700, fontSize: 14),
      ),
    );
  }
}

class SpectatorResultsPromoBanner extends StatelessWidget {
  const SpectatorResultsPromoBanner({super.key, this.onBuyTicket});

  final VoidCallback? onBuyTicket;

  @override
  Widget build(BuildContext context) {
    return SpectatorGlassCard(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Royal Ascot VIP',
                  style: AppTypography.headlineSm(Colors.white).copyWith(
                    fontSize: 24,
                    height: 32 / 24,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Đặt vé ngay cho sự kiện tiếp theo',
                  style: AppTypography.bodyMd(
                    RefereeColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          FilledButton(
            onPressed: onBuyTicket,
            style: FilledButton.styleFrom(
              backgroundColor: RefereeColors.championshipGold,
              foregroundColor: const Color(0xFF101C2E),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Mua Vé',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
