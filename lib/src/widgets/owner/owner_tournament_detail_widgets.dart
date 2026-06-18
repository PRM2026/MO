import 'package:flutter/material.dart';

import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../models/owner_tournament_detail.dart';
import '../../utils/currency_format.dart';
import '../news/news_network_image.dart';
import '../referee/referee_glass_card.dart';

class OwnerTournamentDetailHero extends StatelessWidget {
  const OwnerTournamentDetailHero({super.key, required this.detail});

  final OwnerTournamentDetail detail;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Stack(
          fit: StackFit.expand,
          children: [
            detail.bannerUrl.isNotEmpty
                ? NewsNetworkImage(imageUrl: detail.bannerUrl)
                : const ColoredBox(color: RefereeColors.surfaceContainer),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    RefereeColors.portalSurface.withValues(alpha: 0.97),
                  ],
                  stops: const [0.25, 1],
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatusBadge(label: detail.statusLabel),
                  const SizedBox(height: 12),
                  Text(
                    detail.name,
                    style: AppTypography.displayMd(Colors.white),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color: RefereeColors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          detail.location,
                          style: AppTypography.bodyMd(
                            RefereeColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
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

class OwnerTournamentOverview extends StatelessWidget {
  const OwnerTournamentOverview({super.key, required this.detail});

  final OwnerTournamentDetail detail;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _MetricCard(
              width: width,
              icon: Icons.calendar_today_outlined,
              label: 'Thời gian thi đấu',
              value: _dateRange(detail.startAt, detail.endAt),
            ),
            _MetricCard(
              width: width,
              icon: Icons.how_to_reg_outlined,
              label: 'Thời gian đăng ký',
              value: _dateRange(
                detail.registrationOpenAt,
                detail.registrationCloseAt,
              ),
            ),
            _MetricCard(
              width: width,
              icon: Icons.groups_outlined,
              label: 'Số đội',
              value: detail.teamRangeLabel,
            ),
            _MetricCard(
              width: width,
              icon: Icons.pets_outlined,
              label: 'Ngựa mỗi chủ',
              value: detail.horseRangeLabel,
            ),
          ],
        );
      },
    );
  }
}

class OwnerTournamentTextSection extends StatelessWidget {
  const OwnerTournamentTextSection({
    super.key,
    required this.title,
    required this.content,
  });

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return RefereeGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.headlineSm(RefereeColors.onSurface)),
          const SizedBox(height: 12),
          Text(
            content.isEmpty ? 'Chưa cập nhật.' : content,
            style: AppTypography.bodyMd(RefereeColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class OwnerTournamentRacesSection extends StatelessWidget {
  const OwnerTournamentRacesSection({
    super.key,
    required this.races,
    required this.tournamentStatus,
    this.onInviteJockey,
  });

  final List<OwnerTournamentRace> races;
  final String tournamentStatus;
  final ValueChanged<OwnerTournamentRace>? onInviteJockey;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Các cuộc đua (${races.length})',
          style: AppTypography.headlineSm(RefereeColors.onSurface),
        ),
        const SizedBox(height: 12),
        if (races.isEmpty)
          RefereeGlassCard(
            child: Text(
              'Giải đấu chưa có cuộc đua.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMd(RefereeColors.onSurfaceVariant),
            ),
          )
        else
          ...races.map(
            (race) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _RaceCard(
                race: race,
                canInviteJockey: _canInviteJockey(
                  race: race,
                  tournamentStatus: tournamentStatus,
                ),
                onInviteJockey: onInviteJockey == null
                    ? null
                    : () => onInviteJockey!(race),
              ),
            ),
          ),
      ],
    );
  }
}

class _RaceCard extends StatelessWidget {
  const _RaceCard({
    required this.race,
    required this.canInviteJockey,
    this.onInviteJockey,
  });

  final OwnerTournamentRace race;
  final bool canInviteJockey;
  final VoidCallback? onInviteJockey;

  @override
  Widget build(BuildContext context) {
    return RefereeGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  race.name,
                  style: AppTypography.headlineSm(RefereeColors.onSurface),
                ),
              ),
              const SizedBox(width: 12),
              _StatusBadge(label: race.statusLabel),
            ],
          ),
          const SizedBox(height: 16),
          _RaceInfo(icon: Icons.straighten_outlined, label: race.distance),
          const SizedBox(height: 8),
          _RaceInfo(
            icon: Icons.schedule_outlined,
            label: _dateRange(race.scheduledStartAt, race.scheduledEndAt),
          ),
          const SizedBox(height: 8),
          _RaceInfo(
            icon: Icons.location_on_outlined,
            label: race.venue.isEmpty ? 'Chưa cập nhật địa điểm' : race.venue,
          ),
          const SizedBox(height: 8),
          _RaceInfo(icon: Icons.groups_outlined, label: race.participantLabel),
          const SizedBox(height: 8),
          _RaceInfo(
            icon: Icons.payments_outlined,
            label: 'Phí tham gia: ${formatVnd(race.entryFee)}',
          ),
          if (race.prizes.isNotEmpty) ...[
            const SizedBox(height: 16),
            Divider(color: Colors.white.withValues(alpha: 0.1)),
            const SizedBox(height: 8),
            Text(
              'Giải thưởng',
              style: AppTypography.labelCaps(RefereeColors.championshipGold),
            ),
            const SizedBox(height: 8),
            ...race.prizes.map(
              (prize) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  _prizeLabel(prize),
                  style: AppTypography.bodySm(RefereeColors.onSurfaceVariant),
                ),
              ),
            ),
          ],
          if (canInviteJockey && onInviteJockey != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onInviteJockey,
                icon: const Icon(Icons.mail_outline),
                label: const Text('Mời jockey'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: RefereeColors.championshipGold,
                  side: const BorderSide(
                    color: RefereeColors.championshipGold,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

bool _canInviteJockey({
  required OwnerTournamentRace race,
  required String tournamentStatus,
}) {
  const terminalTournamentStatuses = {
    'COMPLETED',
    'CANCELLED',
    'REGISTRATION_CLOSED',
  };
  const terminalRaceStatuses = {'COMPLETED', 'CANCELLED', 'RESULT_CONFIRMED'};
  return !terminalTournamentStatuses.contains(tournamentStatus) &&
      !terminalRaceStatuses.contains(race.status);
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.width,
    required this.icon,
    required this.label,
    required this.value,
  });

  final double width;
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: RefereeGlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: RefereeColors.championshipGold, size: 22),
            const SizedBox(height: 10),
            Text(
              label,
              style: AppTypography.bodySm(RefereeColors.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodyMd(
                RefereeColors.onSurface,
              ).copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: RefereeColors.championshipGold.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: RefereeColors.championshipGold.withValues(alpha: 0.35),
        ),
      ),
      child: Text(
        label,
        style: AppTypography.labelCaps(
          RefereeColors.championshipGold,
        ).copyWith(fontSize: 10),
      ),
    );
  }
}

class _RaceInfo extends StatelessWidget {
  const _RaceInfo({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: RefereeColors.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodySm(RefereeColors.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

String _dateRange(DateTime? start, DateTime? end) {
  if (start == null && end == null) return 'Chưa cập nhật';
  if (start == null) return 'Đến ${_formatDateTime(end!)}';
  if (end == null) return 'Từ ${_formatDateTime(start)}';
  return '${_formatDateTime(start)} - ${_formatDateTime(end)}';
}

String _formatDateTime(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$day/$month/${date.year} $hour:$minute';
}

String _prizeLabel(OwnerRacePrize prize) {
  final rank = prize.rank == null ? 'Hạng' : 'Hạng ${prize.rank}';
  final parts = <String>[];
  if (prize.amount > 0) parts.add(formatVnd(prize.amount));
  if (prize.itemName.isNotEmpty) parts.add(prize.itemName);
  return parts.isEmpty ? rank : '$rank: ${parts.join(' + ')}';
}
