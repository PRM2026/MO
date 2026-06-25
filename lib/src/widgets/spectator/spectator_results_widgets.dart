import 'package:flutter/material.dart';

import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../models/spectator_models.dart';
import 'spectator_glass_card.dart';

class SpectatorResultsHero extends StatelessWidget {
  const SpectatorResultsHero({super.key});

  @override
  Widget build(BuildContext context) {
    return SpectatorGlassCard(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        height: 144,
        width: double.infinity,
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(
                Icons.emoji_events_outlined,
                color: RefereeColors.championshipGold.withValues(alpha: 0.9),
                size: 36,
              ),
              const SizedBox(height: 12),
              Text(
                'Ket qua dua ngua',
                style: AppTypography.displayLg(
                  RefereeColors.championshipGold,
                ).copyWith(fontSize: 32, height: 40 / 32),
              ),
              const SizedBox(height: 4),
              Text(
                'Thong ke top 3 cua cac chang dua da co ket qua',
                style: AppTypography.bodyMd(RefereeColors.onSurfaceVariant),
              ),
            ],
          ),
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

  final SpectatorResultCategory selected;
  final ValueChanged<SpectatorResultCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final (filter, label) in _resultFilters) ...[
            _FilterChip(
              label: label,
              selected: selected == filter,
              onTap: () => onSelected(filter),
            ),
            if (filter != _resultFilters.last.$1) const SizedBox(width: 12),
          ],
        ],
      ),
    );
  }
}

const _resultFilters = [
  (SpectatorResultCategory.all, 'Tat ca'),
  (SpectatorResultCategory.recent, 'Gan day'),
  (SpectatorResultCategory.verified, 'Da xac thuc'),
];

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

  final SpectatorResultGroup group;
  final VoidCallback? onLeaderboardTap;

  @override
  Widget build(BuildContext context) {
    final topFinishers = group.finishers.take(3).toList(growable: false);

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
                              style: AppTypography.headlineSm(
                                Colors.white,
                              ).copyWith(fontSize: 24, height: 32 / 24),
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
                Divider(height: 1, color: Colors.white.withValues(alpha: 0.05)),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      for (final finisher in topFinishers) ...[
                        _FinisherRow(finisher: finisher),
                        if (finisher != topFinishers.last)
                          const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
                if (group.showLeaderboardAction || onLeaderboardTap != null)
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
                        'Xem chi tiet bang xep hang',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: ColoredBox(
              color: RefereeColors.championshipGold,
              child: SizedBox(width: 4),
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
                ).copyWith(fontWeight: FontWeight.w500, letterSpacing: -0.14),
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
