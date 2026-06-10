import 'package:flutter/material.dart';

import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../models/assigned_race_item.dart';
import '../news/news_network_image.dart';
import 'referee_glass_card.dart';

class RefereeAssignedRaceCard extends StatelessWidget {
  const RefereeAssignedRaceCard({
    super.key,
    required this.race,
    this.onAction,
  });

  final AssignedRaceItem race;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final card = RefereeGlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _RaceHero(race: race),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _MetaGrid(meta: race.meta),
                const SizedBox(height: 16),
                _ActionButton(race: race, onPressed: onAction),
              ],
            ),
          ),
        ],
      ),
    );

    if (!race.dimmed) {
      return ClipRRect(borderRadius: BorderRadius.circular(16), child: card);
    }

    return Opacity(
      opacity: 0.8,
      child: ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          0.5, 0, 0, 0, 0,
          0, 0.5, 0, 0, 0,
          0, 0, 0.5, 0, 0,
          0, 0, 0, 1, 0,
        ]),
        child: ClipRRect(borderRadius: BorderRadius.circular(16), child: card),
      ),
    );
  }
}

class _RaceHero extends StatelessWidget {
  const _RaceHero({required this.race});

  final AssignedRaceItem race;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: Stack(
        fit: StackFit.expand,
        children: [
          NewsNetworkImage(imageUrl: race.imageUrl),
          Positioned(
            top: 16,
            left: 16,
            child: _StatusBadge(status: race.status, label: race.statusLabel),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    RefereeColors.portalSurface,
                    RefereeColors.portalSurface.withValues(alpha: 0),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      race.raceCode,
                      style: AppTypography.labelCaps(RefereeColors.tertiary)
                          .copyWith(fontSize: 13),
                    ),
                    Text(
                      race.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.headlineSm(Colors.white)
                          .copyWith(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.label});

  final AssignedRaceStatus status;
  final String label;

  @override
  Widget build(BuildContext context) {
    final style = switch (status) {
      AssignedRaceStatus.live => (
          RefereeColors.statusRed,
          Colors.white,
          true,
        ),
      AssignedRaceStatus.ready => (
          RefereeColors.successEmerald,
          Colors.white,
          false,
        ),
      AssignedRaceStatus.pendingResults => (
          RefereeColors.tertiary,
          RefereeColors.onTertiary,
          false,
        ),
      AssignedRaceStatus.upcoming => (
          const Color(0xFF37342F),
          RefereeColors.onSurfaceVariant,
          false,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: style.$1,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (style.$3)
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
            style: AppTypography.labelCaps(style.$2).copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _MetaGrid extends StatelessWidget {
  const _MetaGrid({required this.meta});

  final AssignedRaceMeta meta;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _MetaItem(icon: Icons.location_on_outlined, label: meta.location)),
            Expanded(child: _MetaItem(icon: Icons.schedule_outlined, label: meta.schedule)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _MetaItem(icon: Icons.route_outlined, label: meta.lanes)),
            Expanded(child: _MetaItem(icon: Icons.groups_outlined, label: meta.horses)),
          ],
        ),
      ],
    );
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: RefereeColors.tertiary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelCaps(RefereeColors.onSurfaceVariant)
                .copyWith(fontWeight: FontWeight.w500, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.race, this.onPressed});

  final AssignedRaceItem race;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final labelStyle = AppTypography.labelCaps(
      race.actionEnabled
          ? (race.actionFilled
              ? RefereeColors.onTertiary
              : RefereeColors.tertiary)
          : RefereeColors.onSurfaceVariant.withValues(alpha: 0.5),
    ).copyWith(fontSize: 13, letterSpacing: 0.3);

    Widget child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(race.actionLabel, style: labelStyle),
        const SizedBox(width: 8),
        Icon(
          _actionIcon,
          size: 18,
          color: labelStyle.color,
        ),
      ],
    );

    if (race.actionFilled && race.actionEnabled) {
      return FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: RefereeColors.tertiary,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: child,
      );
    }

    if (race.actionSecondary) {
      return OutlinedButton(
        onPressed: race.actionEnabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: RefereeColors.onSurfaceVariant,
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          backgroundColor: Colors.white.withValues(alpha: 0.05),
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: child,
      );
    }

    return OutlinedButton(
      onPressed: race.actionEnabled ? onPressed : null,
      style: OutlinedButton.styleFrom(
        foregroundColor: RefereeColors.tertiary,
        disabledForegroundColor:
            RefereeColors.onSurfaceVariant.withValues(alpha: 0.4),
        side: BorderSide(
          color: race.actionEnabled
              ? RefereeColors.tertiary
              : Colors.white.withValues(alpha: 0.05),
        ),
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: child,
    );
  }

  IconData get _actionIcon {
    if (!race.actionEnabled) return Icons.lock_outline;
    if (race.actionSecondary) return Icons.analytics_outlined;
    return Icons.arrow_forward;
  }
}
