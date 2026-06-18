import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../models/jockey_race_response.dart';
import '../../routes/app_routes.dart';
import '../../utils/currency_format.dart';
import '../../viewmodels/jockey_race_detail_viewmodel.dart';
import '../../widgets/jockey/jockey_app_bar.dart';
import '../../widgets/jockey/jockey_dashboard_widgets.dart';
import '../../widgets/jockey/jockey_state_widgets.dart';
import '../../widgets/referee/referee_glass_card.dart';

class JockeyRaceDetailScreen extends StatefulWidget {
  const JockeyRaceDetailScreen({
    super.key,
    required this.raceId,
    this.viewModel,
  });

  final String raceId;
  final JockeyRaceDetailViewModel? viewModel;

  @override
  State<JockeyRaceDetailScreen> createState() => _JockeyRaceDetailScreenState();
}

class _JockeyRaceDetailScreenState extends State<JockeyRaceDetailScreen> {
  late final JockeyRaceDetailViewModel _viewModel;
  late final bool _ownsViewModel;

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _viewModel =
        widget.viewModel ?? JockeyRaceDetailViewModel(raceId: widget.raceId);
    _viewModel.addListener(_onChanged);
    _viewModel.loadRace();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onChanged);
    if (_ownsViewModel) _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final race = _viewModel.race;

    return Scaffold(
      backgroundColor: RefereeColors.background,
      appBar: const JockeyAppBar(
        showBack: true,
        titleOverride: 'Chi tiết cuộc đua',
        showNotificationAction: false,
      ),
      body: JockeySpeedlineBackground(
        child: _viewModel.isLoading && race == null
            ? const Center(
                child: CircularProgressIndicator(
                  color: RefereeColors.championshipGold,
                ),
              )
            : RefreshIndicator(
                color: RefereeColors.championshipGold,
                onRefresh: _viewModel.loadRace,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.md,
                    40,
                  ),
                  children: [
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 960),
                        child: race == null
                            ? JockeyStateMessage(
                                message:
                                    _viewModel.errorMessage ??
                                    'Không có dữ liệu cuộc đua.',
                                onRetry: _viewModel.loadRace,
                              )
                            : _RaceDetailContent(race: race),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _RaceDetailContent extends StatelessWidget {
  const _RaceDetailContent({required this.race});

  final JockeyRaceResponse race;

  @override
  Widget build(BuildContext context) {
    final statusCode = race.status?.trim().toUpperCase() ?? '';
    final statusColor = _statusColor(statusCode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.sm,
          children: [
            SizedBox(
              width: math.min(
                620,
                MediaQuery.sizeOf(context).width - 2 * AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    race.name?.trim().isNotEmpty == true
                        ? race.name!.trim()
                        : 'Cuộc đua #${race.id}',
                    style: AppTypography.displayLg(
                      RefereeColors.onSurface,
                    ).copyWith(fontSize: 30),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    race.distance?.trim().isNotEmpty == true
                        ? race.distance!.trim()
                        : 'Chưa cập nhật cự ly',
                    style: AppTypography.bodyMd(RefereeColors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            _Badge(label: _statusLabel(statusCode), color: statusColor),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        RefereeGlassCard(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth >= 680
                  ? (constraints.maxWidth - AppSpacing.lg) / 2
                  : constraints.maxWidth;
              return Wrap(
                spacing: AppSpacing.lg,
                runSpacing: AppSpacing.lg,
                children: [
                  _InfoItem(
                    width: width,
                    icon: Icons.schedule_outlined,
                    label: 'Thời gian',
                    value: _dateRange(
                      race.scheduledStartAt,
                      race.scheduledEndAt,
                    ),
                  ),
                  _InfoItem(
                    width: width,
                    icon: Icons.location_on_outlined,
                    label: 'Địa điểm',
                    value: _venueLabel(race),
                  ),
                  _InfoItem(
                    width: width,
                    icon: Icons.person_outline,
                    label: 'Trọng tài',
                    value: race.refereeUsername?.trim().isNotEmpty == true
                        ? race.refereeUsername!.trim()
                        : 'Chưa phân công',
                  ),
                  _InfoItem(
                    width: width,
                    icon: Icons.groups_outlined,
                    label: 'Người tham gia',
                    value: _participantLabel(race),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _TextSection(
          title: 'Ghi chú',
          content: race.note?.trim().isNotEmpty == true
              ? race.note!.trim()
              : 'Chưa có ghi chú.',
        ),
        const SizedBox(height: AppSpacing.lg),
        _PrizesSection(prizes: race.prizes),
        const SizedBox(height: AppSpacing.xl),
        FilledButton.icon(
          key: const Key('open-race-results'),
          onPressed: () => AppRoutes.openJockeyRaceResults(
            context,
            raceId: race.id,
            tournamentId: race.tournamentId,
          ),
          style: FilledButton.styleFrom(
            backgroundColor: RefereeColors.championshipGold,
            foregroundColor: RefereeColors.portalSurface,
            minimumSize: const Size.fromHeight(52),
          ),
          icon: const Icon(Icons.emoji_events_outlined),
          label: const Text('Xem kết quả'),
        ),
      ],
    );
  }
}

class _PrizesSection extends StatelessWidget {
  const _PrizesSection({required this.prizes});

  final List<JockeyRacePrizeResponse> prizes;

  @override
  Widget build(BuildContext context) {
    return RefereeGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Giải thưởng',
            style: AppTypography.headlineSm(RefereeColors.onSurface),
          ),
          const SizedBox(height: AppSpacing.md),
          if (prizes.isEmpty)
            Text(
              'Chưa công bố giải thưởng.',
              style: AppTypography.bodyMd(RefereeColors.onSurfaceVariant),
            )
          else
            for (var index = 0; index < prizes.length; index++) ...[
              _PrizeRow(prize: prizes[index]),
              if (index < prizes.length - 1)
                Divider(color: Colors.white.withValues(alpha: 0.08)),
            ],
        ],
      ),
    );
  }
}

class _PrizeRow extends StatelessWidget {
  const _PrizeRow({required this.prize});

  final JockeyRacePrizeResponse prize;

  @override
  Widget build(BuildContext context) {
    final extras = [
      if (prize.itemName?.trim().isNotEmpty == true) prize.itemName!.trim(),
      if (prize.note?.trim().isNotEmpty == true) prize.note!.trim(),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: RefereeColors.championshipGold.withValues(
              alpha: 0.15,
            ),
            foregroundColor: RefereeColors.championshipGold,
            child: Text(prize.rank?.toString() ?? '–'),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prize.rank == null ? 'Giải thưởng' : 'Hạng ${prize.rank}',
                  style: AppTypography.bodyMd(
                    RefereeColors.onSurface,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
                if (extras.isNotEmpty)
                  Text(
                    extras.join(' • '),
                    style: AppTypography.bodySm(RefereeColors.onSurfaceVariant),
                  ),
              ],
            ),
          ),
          Text(
            formatVnd(prize.amount),
            style: AppTypography.bodyMd(
              RefereeColors.championshipGold,
            ).copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _TextSection extends StatelessWidget {
  const _TextSection({required this.title, required this.content});

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return RefereeGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.headlineSm(RefereeColors.onSurface)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            content,
            style: AppTypography.bodyMd(RefereeColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: RefereeColors.championshipGold),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.labelCaps(
                    RefereeColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTypography.bodyMd(RefereeColors.onSurface),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(label, style: AppTypography.labelCaps(color)),
    );
  }
}

String _statusLabel(String status) {
  return switch (status) {
    'SCHEDULED' => 'Đã lên lịch',
    'CHECK_IN_OPEN' => 'Đang check-in',
    'READY' => 'Sẵn sàng',
    'ONGOING' => 'Đang diễn ra',
    'PENDING_RESULT' => 'Chờ kết quả',
    'RESULT_CONFIRMED' || 'COMPLETED' => 'Đã có kết quả',
    'CANCELLED' => 'Đã hủy',
    'DRAFT' => 'Bản nháp',
    _ => status.isEmpty ? 'Chưa rõ trạng thái' : status,
  };
}

Color _statusColor(String status) {
  return switch (status) {
    'RESULT_CONFIRMED' || 'COMPLETED' => RefereeColors.successEmerald,
    'ONGOING' => RefereeColors.championshipGold,
    'CANCELLED' => RefereeColors.statusRed,
    'PENDING_RESULT' || 'CHECK_IN_OPEN' => RefereeColors.secondary,
    _ => RefereeColors.onSurfaceVariant,
  };
}

String _participantLabel(JockeyRaceResponse race) {
  final limits = switch ((race.minParticipants, race.maxParticipants)) {
    (final int min, final int max) => ' (yêu cầu $min–$max)',
    (final int min, null) => ' (tối thiểu $min)',
    (null, final int max) => ' (tối đa $max)',
    _ => '',
  };
  return '${race.participantCount} người$limits';
}

String _venueLabel(JockeyRaceResponse race) {
  final parts = [
    race.venueName,
    race.venueAddress,
    race.provinceName,
  ].where((value) => value?.trim().isNotEmpty == true).cast<String>();
  final label = parts.map((value) => value.trim()).join(', ');
  return label.isEmpty ? 'Chưa cập nhật địa điểm' : label;
}

String _dateRange(DateTime? start, DateTime? end) {
  if (start == null && end == null) return 'Chưa lên lịch';
  if (start == null) return 'Đến ${_dateTime(end!)}';
  if (end == null) return 'Từ ${_dateTime(start)}';
  return '${_dateTime(start)} – ${_dateTime(end)}';
}

String _dateTime(DateTime value) {
  final local = value.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$day/$month/${local.year} $hour:$minute';
}
