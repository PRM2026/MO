import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../models/jockey_schedule_data.dart';
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
      color: selected ? RefereeColors.championshipGold : Colors.transparent,
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
    if (dates.isEmpty) {
      return Text(
        'Chưa có cuộc đua đã lên lịch.',
        style: AppTypography.bodyMd(RefereeColors.onSurfaceVariant),
      );
    }

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
                            color: RefereeColors.championshipGold.withValues(
                              alpha: 0.15,
                            ),
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
                            ? RefereeColors.championshipGold.withValues(
                                alpha: 0.7,
                              )
                            : RefereeColors.onSurfaceVariant.withValues(
                                alpha: 0.7,
                              ),
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
    required this.onDirections,
    required this.onDetails,
    this.showUnscheduledSections = false,
  });

  final List<JockeyRaceScheduleItem> races;
  final ValueChanged<JockeyRaceScheduleItem> onDirections;
  final ValueChanged<JockeyRaceScheduleItem> onDetails;
  final bool showUnscheduledSections;

  @override
  Widget build(BuildContext context) {
    if (races.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: Text(
            showUnscheduledSections
                ? 'Chưa có lịch thi đấu.'
                : 'Không có cuộc đua trong ngày này.',
            style: AppTypography.bodyMd(RefereeColors.onSurfaceVariant),
          ),
        ),
      );
    }

    final scheduled = races.where((race) => !race.isUnscheduled).toList();
    final unscheduled = races.where((race) => race.isUnscheduled).toList();

    if (showUnscheduledSections && unscheduled.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (scheduled.isNotEmpty)
            _RaceListSection(
              title: 'Đã lên lịch',
              races: scheduled,
              onDirections: onDirections,
              onDetails: onDetails,
            ),
          if (scheduled.isNotEmpty) const SizedBox(height: AppSpacing.xl),
          _RaceListSection(
            title: 'Chưa lên lịch',
            races: unscheduled,
            onDirections: onDirections,
            onDetails: onDetails,
          ),
        ],
      );
    }

    return _RaceListSection(
      races: races,
      onDirections: onDirections,
      onDetails: onDetails,
    );
  }
}

class _RaceListSection extends StatelessWidget {
  const _RaceListSection({
    required this.races,
    required this.onDirections,
    required this.onDetails,
    this.title,
  });

  final String? title;
  final List<JockeyRaceScheduleItem> races;
  final ValueChanged<JockeyRaceScheduleItem> onDirections;
  final ValueChanged<JockeyRaceScheduleItem> onDetails;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: AppTypography.headlineSm(
              RefereeColors.onSurface,
            ).copyWith(fontSize: 20),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        for (var i = 0; i < races.length; i++) ...[
          _TimelineRaceEntry(
            race: races[i],
            isLast: i == races.length - 1,
            onDirections: () => onDirections(races[i]),
            onDetails: () => onDetails(races[i]),
          ),
          if (i < races.length - 1) const SizedBox(height: AppSpacing.xl),
        ],
      ],
    );
  }
}

class _TimelineRaceEntry extends StatelessWidget {
  const _TimelineRaceEntry({
    required this.race,
    required this.isLast,
    required this.onDirections,
    required this.onDetails,
  });

  final JockeyRaceScheduleItem race;
  final bool isLast;
  final VoidCallback onDirections;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) {
    final dotColor = JockeyScheduleData.statusColor(race.statusCode);

    return Padding(
      padding: const EdgeInsets.only(left: 40),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -31,
            top: 18,
            bottom: isLast ? null : -AppSpacing.xl,
            child: Column(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: RefereeColors.background,
                      width: 4,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: RefereeColors.championshipGold.withValues(
                        alpha: 0.25,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                race.timeLabel.toUpperCase(),
                style: AppTypography.labelCaps(
                  dotColor,
                ).copyWith(letterSpacing: 1),
              ),
              const SizedBox(height: 4),
              Text(
                race.eventName,
                style: AppTypography.headlineSm(
                  RefereeColors.onSurface,
                ).copyWith(fontSize: 22),
              ),
              const SizedBox(height: AppSpacing.md),
              JockeyScheduleRaceCard(
                race: race,
                onDirections: onDirections,
                onDetails: onDetails,
              ),
            ],
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
    required this.onDirections,
    required this.onDetails,
  });

  final JockeyRaceScheduleItem race;
  final VoidCallback onDirections;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) {
    final statusColor = JockeyScheduleData.statusColor(race.statusCode);

    return RefereeGlassCard(
      padding: const EdgeInsets.all(20),
      highlighted: race.statusCode == 'ONGOING' || race.statusCode == 'LIVE',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Badge(label: race.statusLabel, color: statusColor),
              _Badge(
                label: race.distanceLabel,
                color: RefereeColors.championshipGold,
                icon: Icons.straighten_outlined,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 640;
              final infoBlocks = [
                _InfoBlock(
                  icon: Icons.schedule_outlined,
                  label: 'Thời gian',
                  value: race.timeLabel,
                  iconColor: statusColor,
                ),
                _InfoBlock(
                  icon: Icons.location_on_outlined,
                  label: 'Địa điểm',
                  value: race.venue,
                  iconColor: statusColor,
                ),
                _InfoBlock(
                  icon: Icons.person_outline,
                  label: 'Trọng tài',
                  value: race.refereeLabel,
                  iconColor: statusColor,
                ),
                _InfoBlock(
                  icon: Icons.groups_outlined,
                  label: 'Số người tham gia',
                  value: race.participantLabel,
                  iconColor: statusColor,
                ),
              ];

              if (isWide) {
                return Wrap(
                  runSpacing: AppSpacing.md,
                  children: [
                    for (final block in infoBlocks)
                      SizedBox(width: constraints.maxWidth / 2, child: block),
                  ],
                );
              }

              return Column(
                children: [
                  for (var i = 0; i < infoBlocks.length; i++) ...[
                    infoBlocks[i],
                    if (i < infoBlocks.length - 1)
                      const SizedBox(height: AppSpacing.md),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            key: Key('race-details-${race.id}'),
            onPressed: onDetails,
            style: FilledButton.styleFrom(
              backgroundColor: RefereeColors.championshipGold,
              foregroundColor: RefereeColors.portalSurface,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.visibility_outlined, size: 18),
            label: const Text('Xem chi tiết'),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: onDirections,
            style: OutlinedButton.styleFrom(
              foregroundColor: RefereeColors.onSurface,
              side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.directions_outlined, size: 18),
            label: const Text('Chỉ đường'),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color, this.icon});

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
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
      crossAxisAlignment: CrossAxisAlignment.start,
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
