import 'package:flutter/material.dart';

import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../models/jockey_schedule_data.dart';
import '../news/news_network_image.dart';
import '../referee/referee_glass_card.dart';

class JockeyScheduleViewToggle extends StatelessWidget {
  const JockeyScheduleViewToggle({
    super.key,
    required this.mode,
    required this.onChanged,
  });

  final JockeyScheduleViewMode mode;
  final ValueChanged<JockeyScheduleViewMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: RefereeColors.portalSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleChip(
            label: 'Lịch',
            selected: mode == JockeyScheduleViewMode.calendar,
            onTap: () => onChanged(JockeyScheduleViewMode.calendar),
          ),
          _ToggleChip(
            label: 'Danh sách',
            selected: mode == JockeyScheduleViewMode.list,
            onTap: () => onChanged(JockeyScheduleViewMode.list),
          ),
        ],
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  const _ToggleChip({
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
      color: selected
          ? RefereeColors.championshipGold
          : Colors.transparent,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            label,
            style: AppTypography.labelCaps(
              selected
                  ? RefereeColors.portalSurface
                  : RefereeColors.onSurfaceVariant.withValues(alpha: 0.6),
            ).copyWith(fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}

class JockeyScheduleDateSelector extends StatelessWidget {
  const JockeyScheduleDateSelector({
    super.key,
    required this.dates,
    required this.selectedDateKey,
    required this.onDateSelected,
  });

  final List<JockeyScheduleDateItem> dates;
  final String? selectedDateKey;
  final ValueChanged<String> onDateSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final date = dates[index];
          final selected = date.dateKey == selectedDateKey;

          return Material(
            color: selected
                ? RefereeColors.portalSurface
                : RefereeColors.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () => onDateSelected(date.dateKey),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected
                        ? RefereeColors.championshipGold.withValues(alpha: 0.4)
                        : Colors.white.withValues(alpha: 0.05),
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: RefereeColors.championshipGold
                                .withValues(alpha: 0.15),
                            blurRadius: 20,
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      date.monthLabel.toUpperCase(),
                      style: AppTypography.labelCaps(
                        selected
                            ? RefereeColors.championshipGold
                                .withValues(alpha: 0.7)
                            : RefereeColors.onSurfaceVariant
                                .withValues(alpha: 0.7),
                      ).copyWith(fontSize: 11),
                    ),
                    Text(
                      '${date.day}',
                      style: AppTypography.headlineSm(
                        selected
                            ? RefereeColors.championshipGold
                            : RefereeColors.onSurface,
                      ).copyWith(fontSize: 22),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class JockeyScheduleTimeline extends StatelessWidget {
  const JockeyScheduleTimeline({
    super.key,
    required this.races,
    required this.onConfirm,
    required this.onDirections,
  });

  final List<JockeyRaceScheduleItem> races;
  final ValueChanged<String> onConfirm;
  final ValueChanged<JockeyRaceScheduleItem> onDirections;

  @override
  Widget build(BuildContext context) {
    if (races.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: Text(
            'Không có cuộc đua trong ngày này.',
            style: AppTypography.bodyMd(RefereeColors.onSurfaceVariant),
          ),
        ),
      );
    }

    return Stack(
      children: [
        Positioned(
          left: 9,
          top: 8,
          bottom: 8,
          child: Container(
            width: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  RefereeColors.championshipGold.withValues(alpha: 0.3),
                  RefereeColors.championshipGold.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
                stops: const [0, 0.15, 0.85, 1],
              ),
            ),
          ),
        ),
        Column(
          children: [
            for (var i = 0; i < races.length; i++) ...[
              _TimelineRaceEntry(
                race: races[i],
                isLast: i == races.length - 1,
                onConfirm: () => onConfirm(races[i].id),
                onDirections: () => onDirections(races[i]),
              ),
              if (i < races.length - 1) const SizedBox(height: 48),
            ],
          ],
        ),
      ],
    );
  }
}

class _TimelineRaceEntry extends StatelessWidget {
  const _TimelineRaceEntry({
    required this.race,
    required this.isLast,
    required this.onConfirm,
    required this.onDirections,
  });

  final JockeyRaceScheduleItem race;
  final bool isLast;
  final VoidCallback onConfirm;
  final VoidCallback onDirections;

  @override
  Widget build(BuildContext context) {
    final isActive = race.isPending;
    final dotColor = isActive
        ? RefereeColors.championshipGold
        : RefereeColors.onSurfaceVariant.withValues(alpha: 0.4);

    return Padding(
      padding: const EdgeInsets.only(left: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: -38,
                top: 16,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: RefereeColors.background,
                      width: 4,
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    race.timeLabel.toUpperCase(),
                    style: AppTypography.labelCaps(
                      isActive
                          ? RefereeColors.championshipGold
                          : RefereeColors.onSurfaceVariant,
                    ).copyWith(letterSpacing: 1),
                  ),
                  Text(
                    race.eventName,
                    style: AppTypography.headlineSm(
                      RefereeColors.onSurface,
                    ).copyWith(
                      fontSize: 22,
                      color: race.isDimmed
                          ? RefereeColors.onSurface.withValues(alpha: 0.8)
                          : RefereeColors.onSurface,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          JockeyScheduleRaceCard(
            race: race,
            onConfirm: onConfirm,
            onDirections: onDirections,
          ),
        ],
      ),
    );
  }
}

class JockeyScheduleRaceCard extends StatelessWidget {
  const JockeyScheduleRaceCard({
    super.key,
    required this.race,
    required this.onConfirm,
    required this.onDirections,
  });

  final JockeyRaceScheduleItem race;
  final VoidCallback onConfirm;
  final VoidCallback onDirections;

  @override
  Widget build(BuildContext context) {
    final statusColor = JockeyScheduleData.statusColor(race.status);
    final iconColor = race.isPending
        ? RefereeColors.championshipGold
        : RefereeColors.onSurfaceVariant.withValues(alpha: 0.6);

    return Opacity(
      opacity: race.isDimmed ? 0.9 : 1,
      child: RefereeGlassCard(
        padding: EdgeInsets.zero,
        highlighted: race.isPending,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: SizedBox(
                height: 128,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ColorFiltered(
                      colorFilter: race.isDimmed
                          ? const ColorFilter.matrix(<double>[
                              0.2126, 0.7152, 0.0722, 0, 0,
                              0.2126, 0.7152, 0.0722, 0, 0,
                              0.2126, 0.7152, 0.0722, 0, 0,
                              0, 0, 0, 1, 0,
                            ])
                          : const ColorFilter.mode(
                              Colors.transparent,
                              BlendMode.multiply,
                            ),
                      child: Opacity(
                        opacity: race.isDimmed ? 0.4 : 0.6,
                        child: NewsNetworkImage(imageUrl: race.imageUrl),
                      ),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            RefereeColors.portalSurface,
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      bottom: 16,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _Badge(
                            label: race.laneLabel,
                            color: race.isPending
                                ? RefereeColors.championshipGold
                                : RefereeColors.onSurfaceVariant,
                            filled: race.isPending,
                          ),
                          _Badge(
                            label: JockeyScheduleData.statusLabel(race.status),
                            color: statusColor,
                            icon: race.isConfirmed
                                ? Icons.check_circle_outline
                                : null,
                            filled: race.isPending,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 480;
                      final horseInfo = _InfoBlock(
                        icon: Icons.pets_outlined,
                        label: 'Chiến mã',
                        value: race.horseName,
                        iconColor: iconColor,
                      );
                      final venueInfo = _InfoBlock(
                        icon: Icons.location_on_outlined,
                        label: 'Địa điểm',
                        value: race.venue,
                        iconColor: iconColor,
                      );

                      if (isWide) {
                        return Row(
                          children: [
                            Expanded(child: horseInfo),
                            Expanded(child: venueInfo),
                          ],
                        );
                      }

                      return Column(
                        children: [
                          horseInfo,
                          const SizedBox(height: 12),
                          venueInfo,
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  if (race.isPending)
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: onConfirm,
                            style: FilledButton.styleFrom(
                              backgroundColor: RefereeColors.championshipGold,
                              foregroundColor: RefereeColors.portalSurface,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.check_circle_outline, size: 18),
                            label: const Text('Xác nhận tham gia'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onDirections,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: RefereeColors.onSurface,
                              side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.directions_outlined, size: 18),
                            label: const Text('Chỉ đường'),
                          ),
                        ),
                      ],
                    )
                  else
                    OutlinedButton.icon(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: RefereeColors.onSurfaceVariant,
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.info_outline, size: 18),
                      label: const Text('Xem chi tiết cuộc đua'),
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

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.color,
    this.icon,
    this.filled = false,
  });

  final String label;
  final Color color;
  final IconData? icon;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: filled ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTypography.labelCaps(color).copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.labelCaps(
                  RefereeColors.onSurfaceVariant,
                ).copyWith(fontWeight: FontWeight.w400),
              ),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyMd(RefereeColors.onSurface),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
