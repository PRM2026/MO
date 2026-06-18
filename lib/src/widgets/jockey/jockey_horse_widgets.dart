import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../models/jockey_horse_data.dart';
import '../referee/referee_glass_card.dart';

class JockeyHorseAssignmentCard extends StatelessWidget {
  const JockeyHorseAssignmentCard({
    super.key,
    required this.assignment,
    required this.onTap,
  });

  final JockeyHorseAssignmentItem assignment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return RefereeGlassCard(
      key: Key('horse-assignment-${assignment.invitationId}'),
      onTap: onTap,
      highlighted: assignment.hasRaceDetail,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: RefereeColors.championshipGold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.pets_outlined,
                  color: RefereeColors.championshipGold,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assignment.horseName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.headlineSm(RefereeColors.onSurface),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      assignment.ownerUsername,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySm(
                        RefereeColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _StatusBadge(
                label: assignment.assignmentStatusLabel,
                color: RefereeColors.successEmerald,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _AssignmentInfo(
            icon: Icons.emoji_events_outlined,
            label: 'Cuộc đua',
            value: assignment.raceName,
          ),
          const SizedBox(height: AppSpacing.md),
          _AssignmentInfo(
            icon: Icons.stadium_outlined,
            label: 'Giải đấu',
            value: assignment.tournamentName,
          ),
          const SizedBox(height: AppSpacing.md),
          _AssignmentInfo(
            icon: Icons.schedule_outlined,
            label: 'Lịch thi đấu',
            value: assignment.scheduledStartLabel,
          ),
          const SizedBox(height: AppSpacing.md),
          _AssignmentInfo(
            icon: Icons.payments_outlined,
            label: 'Thù lao',
            value: assignment.remunerationLabel,
            valueColor: RefereeColors.championshipGold,
          ),
          const SizedBox(height: AppSpacing.lg),
          Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _StatusBadge(
                label: assignment.raceStatusLabel,
                color: _raceStatusColor(assignment.raceStatusCode),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        assignment.hasRaceDetail
                            ? 'Xem cuộc đua'
                            : 'Xem lời mời',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySm(
                          RefereeColors.championshipGold,
                        ).copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right,
                      color: RefereeColors.championshipGold,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AssignmentInfo extends StatelessWidget {
  const _AssignmentInfo({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: RefereeColors.onSurfaceVariant, size: 20),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.labelCaps(
                  RefereeColors.onSurfaceVariant,
                ).copyWith(fontSize: 10),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyMd(
                  valueColor ?? RefereeColors.onSurface,
                ).copyWith(fontWeight: FontWeight.w600),
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
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: AppTypography.labelCaps(color).copyWith(fontSize: 10),
      ),
    );
  }
}

Color _raceStatusColor(String status) {
  return switch (status) {
    'RESULT_CONFIRMED' || 'FINISHED' => RefereeColors.successEmerald,
    'ONGOING' => RefereeColors.championshipGold,
    'CANCELLED' ||
    'DNF' ||
    'DISQUALIFIED' ||
    'ABSENT' => RefereeColors.statusRed,
    'SCHEDULED' ||
    'PUBLISHED' ||
    'OPEN_REGISTRATION' => RefereeColors.secondary,
    _ => RefereeColors.onSurfaceVariant,
  };
}
