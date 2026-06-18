import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../models/jockey_race_result_response.dart';
import '../../repositories/jockey_race_results_repository.dart';
import '../../viewmodels/jockey_race_results_viewmodel.dart';
import '../../widgets/jockey/jockey_app_bar.dart';
import '../../widgets/jockey/jockey_dashboard_widgets.dart';
import '../../widgets/jockey/jockey_state_widgets.dart';
import '../../widgets/referee/referee_glass_card.dart';

class JockeyRaceResultsScreen extends StatefulWidget {
  const JockeyRaceResultsScreen({
    super.key,
    required this.raceId,
    this.tournamentId,
    this.viewModel,
  });

  final String raceId;
  final String? tournamentId;
  final JockeyRaceResultsViewModel? viewModel;

  @override
  State<JockeyRaceResultsScreen> createState() =>
      _JockeyRaceResultsScreenState();
}

class _JockeyRaceResultsScreenState extends State<JockeyRaceResultsScreen> {
  late final JockeyRaceResultsViewModel _viewModel;
  late final bool _ownsViewModel;

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _viewModel =
        widget.viewModel ??
        JockeyRaceResultsViewModel(
          raceId: widget.raceId,
          tournamentId: widget.tournamentId,
        );
    _viewModel.addListener(_onChanged);
    _viewModel.loadResults();
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
    final data = _viewModel.data;

    return Scaffold(
      backgroundColor: RefereeColors.background,
      appBar: const JockeyAppBar(
        showBack: true,
        titleOverride: 'Kết quả cuộc đua',
        showNotificationAction: false,
      ),
      body: JockeySpeedlineBackground(
        child: _viewModel.isLoading && data == null
            ? const Center(
                child: CircularProgressIndicator(
                  color: RefereeColors.championshipGold,
                ),
              )
            : RefreshIndicator(
                color: RefereeColors.championshipGold,
                onRefresh: _viewModel.loadResults,
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
                        constraints: const BoxConstraints(maxWidth: 1100),
                        child: data == null
                            ? JockeyStateMessage(
                                message:
                                    _viewModel.errorMessage ??
                                    'Không có dữ liệu kết quả.',
                                onRetry: _viewModel.loadResults,
                              )
                            : _ResultsContent(
                                data: data,
                                showChallenge: _viewModel.shouldLoadChallenge,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _ResultsContent extends StatelessWidget {
  const _ResultsContent({required this.data, required this.showChallenge});

  final JockeyRaceResultsData data;
  final bool showChallenge;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Bảng kết quả',
          style: AppTypography.displayLg(
            RefereeColors.onSurface,
          ).copyWith(fontSize: 28),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (data.results.isEmpty)
          const JockeyStateMessage(
            message: 'Chưa có kết quả.',
            icon: Icons.emoji_events_outlined,
          )
        else
          ...data.results.map(
            (result) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _ResultCard(
                result: result,
                highlighted: data.isCurrentJockey(result.jockeyId),
              ),
            ),
          ),
        if (showChallenge) ...[
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Xếp hạng Jockey Challenge',
            style: AppTypography.headlineSm(RefereeColors.onSurface),
          ),
          const SizedBox(height: AppSpacing.md),
          if (data.challengeStandings.isEmpty)
            RefereeGlassCard(
              child: Text(
                'Chưa có bảng xếp hạng Jockey Challenge.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMd(RefereeColors.onSurfaceVariant),
              ),
            )
          else
            ...data.challengeStandings.map(
              (standing) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _ChallengeCard(
                  standing: standing,
                  highlighted: data.isCurrentJockey(standing.jockeyId),
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result, required this.highlighted});

  final JockeyRaceResultResponse result;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: Key(
        highlighted
            ? 'current-jockey-result-${result.jockeyId}'
            : 'race-result-${result.id}',
      ),
      child: RefereeGlassCard(
        highlighted: highlighted,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _RankCircle(label: result.rank > 0 ? '${result.rank}' : '–'),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.horseLabel,
                        style: AppTypography.headlineSm(
                          RefereeColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${result.ownerLabel} • ${result.jockeyLabel}',
                        style: AppTypography.bodySm(
                          RefereeColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (highlighted)
                  const _StatusBadge(
                    label: 'Bạn',
                    color: RefereeColors.championshipGold,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _MetricWrap(
              items: [
                ('Thời gian', result.finishTimeLabel),
                ('Điểm challenge', result.challengePointsLabel),
                ('Thưởng jockey', result.jockeyPrizeLabel),
                ('Thanh toán', result.payoutStatusLabel),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _StatusBadge(
                  label: result.statusLabel,
                  color: _resultStatusColor(result.status),
                ),
                if (result.note?.trim().isNotEmpty == true)
                  Text(
                    result.note!.trim(),
                    style: AppTypography.bodySm(RefereeColors.onSurfaceVariant),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({required this.standing, required this.highlighted});

  final JockeyChallengeStandingResponse standing;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: Key(
        highlighted
            ? 'current-jockey-challenge-${standing.jockeyId}'
            : 'challenge-standing-${standing.jockeyId}',
      ),
      child: RefereeGlassCard(
        highlighted: highlighted,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _RankCircle(
              label: standing.challengeRank > 0
                  ? '${standing.challengeRank}'
                  : '–',
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          standing.jockeyLabel,
                          style: AppTypography.headlineSm(
                            RefereeColors.onSurface,
                          ),
                        ),
                      ),
                      if (highlighted)
                        const _StatusBadge(
                          label: 'Bạn',
                          color: RefereeColors.championshipGold,
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${standing.totalPoints} điểm • ${standing.podiumLabel}',
                    style: AppTypography.bodySm(RefereeColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '${standing.prizeLabel} • ${standing.payoutStatusLabel}',
                    style: AppTypography.bodyMd(
                      RefereeColors.championshipGold,
                    ).copyWith(fontWeight: FontWeight.w600),
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

class _MetricWrap extends StatelessWidget {
  const _MetricWrap({required this.items});

  final List<(String, String)> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = constraints.maxWidth >= 680
            ? (constraints.maxWidth - AppSpacing.md) / 2
            : constraints.maxWidth;
        return Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            for (final item in items)
              SizedBox(
                width: itemWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.$1,
                      style: AppTypography.labelCaps(
                        RefereeColors.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      item.$2,
                      style: AppTypography.bodyMd(RefereeColors.onSurface),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _RankCircle extends StatelessWidget {
  const _RankCircle({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 24,
      backgroundColor: RefereeColors.championshipGold.withValues(alpha: 0.15),
      foregroundColor: RefereeColors.championshipGold,
      child: Text(
        label,
        style: AppTypography.headlineSm(RefereeColors.championshipGold),
      ),
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

Color _resultStatusColor(String? status) {
  return switch ((status ?? '').toUpperCase()) {
    'FINISHED' => RefereeColors.successEmerald,
    'DNF' || 'DISQUALIFIED' || 'ABSENT' => RefereeColors.statusRed,
    _ => RefereeColors.onSurfaceVariant,
  };
}
