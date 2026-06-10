import 'package:flutter/material.dart';

import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../models/referee_dashboard_data.dart';
import '../news/news_network_image.dart';
import 'referee_glass_card.dart';

class RefereeRaceCard extends StatelessWidget {
  const RefereeRaceCard({
    super.key,
    required this.race,
    this.onAction,
  });

  final RefereeRaceItem race;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return RefereeGlassCard(
      padding: EdgeInsets.zero,
      highlighted: race.highlighted,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 192,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ColorFiltered(
                  colorFilter: const ColorFilter.matrix(<double>[
                    0.7, 0, 0, 0, 0,
                    0, 0.7, 0, 0, 0,
                    0, 0, 0.7, 0, 0,
                    0, 0, 0, 1, 0,
                  ]),
                  child: NewsNetworkImage(imageUrl: race.imageUrl),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: _StatusBadge(status: race.status, label: race.statusLabel),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            race.title,
                            style: AppTypography.headlineSm(
                              RefereeColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            race.subtitle,
                            style: AppTypography.labelCaps(
                              RefereeColors.onSurfaceVariant,
                            ).copyWith(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      _statusIcon(race.status),
                      color: RefereeColors.onSurfaceVariant,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                RefereeSpeedLine(
                  opacity: race.status == RefereeRaceStatus.live ? 1 : 0.2,
                ),
                const SizedBox(height: 16),
                for (final row in race.details) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        row.label,
                        style: AppTypography.labelCaps(
                          RefereeColors.onSurfaceVariant,
                        ).copyWith(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        row.value,
                        style: AppTypography.labelCaps(
                          row.valueColor ?? RefereeColors.onSurface,
                        ).copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                const SizedBox(height: 8),
                _ActionButton(
                  label: race.actionLabel,
                  filled: race.actionFilled,
                  enabled: race.actionEnabled,
                  onPressed: onAction,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _statusIcon(RefereeRaceStatus status) {
    switch (status) {
      case RefereeRaceStatus.live:
        return Icons.timer_outlined;
      case RefereeRaceStatus.pending:
        return Icons.done_all;
      case RefereeRaceStatus.scheduled:
        return Icons.event_outlined;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.label});

  final RefereeRaceStatus status;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = switch (status) {
      RefereeRaceStatus.live => (
          RefereeColors.statusRed,
          Colors.white,
          true,
        ),
      RefereeRaceStatus.pending => (
          RefereeColors.tertiary,
          RefereeColors.onTertiary,
          false,
        ),
      RefereeRaceStatus.scheduled => (
          RefereeColors.secondaryContainer,
          RefereeColors.onSecondaryContainer,
          false,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.$1,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (colors.$3)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 6),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          Text(
            label,
            style: AppTypography.labelCaps(colors.$2).copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.filled,
    required this.enabled,
    this.onPressed,
  });

  final String label;
  final bool filled;
  final bool enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final style = filled
        ? FilledButton.styleFrom(
            backgroundColor: RefereeColors.tertiary,
            foregroundColor: RefereeColors.onTertiary,
            disabledBackgroundColor:
                RefereeColors.tertiary.withValues(alpha: 0.4),
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          )
        : OutlinedButton.styleFrom(
            foregroundColor: enabled
                ? RefereeColors.tertiary
                : RefereeColors.onSurfaceVariant,
            side: BorderSide(
              color: enabled
                  ? RefereeColors.tertiary
                  : RefereeColors.outlineVariant,
            ),
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          );

    final child = Text(
      label,
      style: AppTypography.labelCaps(
        filled ? RefereeColors.onTertiary : RefereeColors.tertiary,
      ).copyWith(fontSize: 13, letterSpacing: 0.3),
    );

    if (filled) {
      return FilledButton(
        onPressed: enabled ? onPressed : null,
        style: style,
        child: child,
      );
    }

    return OutlinedButton(
      onPressed: enabled ? onPressed : null,
      style: style,
      child: child,
    );
  }
}
