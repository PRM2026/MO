import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/referee_colors.dart';
import '../../models/spectator_models.dart';
import '../../viewmodels/spectator_race_results_viewmodel.dart';
import '../../widgets/spectator/spectator_app_bar.dart';
import '../../widgets/spectator/spectator_glass_card.dart';

class SpectatorRaceResultsScreen extends StatefulWidget {
  const SpectatorRaceResultsScreen({
    super.key,
    required this.raceId,
    this.race,
    this.initialGroup,
    this.viewModel,
  });

  final String raceId;
  final SpectatorRaceItem? race;
  final SpectatorResultGroup? initialGroup;
  final SpectatorRaceResultsViewModel? viewModel;

  @override
  State<SpectatorRaceResultsScreen> createState() =>
      _SpectatorRaceResultsScreenState();
}

class _SpectatorRaceResultsScreenState
    extends State<SpectatorRaceResultsScreen> {
  late final SpectatorRaceResultsViewModel _viewModel;
  late final bool _ownsViewModel;

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _viewModel =
        widget.viewModel ??
        SpectatorRaceResultsViewModel(
          raceId: widget.raceId,
          race: widget.race,
          initialGroup: widget.initialGroup,
        );
    _viewModel.load();
  }

  @override
  void dispose() {
    if (_ownsViewModel) {
      _viewModel.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
        final group = _viewModel.data;

        return Scaffold(
          backgroundColor: RefereeColors.background,
          appBar: const SpectatorAppBar(
            titleOverride: 'Bang xep hang',
            showProfileAvatar: false,
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.lg,
              AppSpacing.screenPadding,
              120,
            ),
            children: [
              if (_viewModel.isLoading)
                const _LeaderboardLoadingState()
              else if (_viewModel.errorMessage != null)
                _LeaderboardErrorState(
                  message: _viewModel.errorMessage!,
                  onRetry: _viewModel.retry,
                )
              else if (group == null || group.finishers.isEmpty)
                const _LeaderboardEmptyState()
              else
                _LeaderboardContent(group: group),
            ],
          ),
        );
      },
    );
  }
}

class _LeaderboardContent extends StatelessWidget {
  const _LeaderboardContent({required this.group});

  final SpectatorResultGroup group;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SpectatorGlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    group.verified
                        ? Icons.verified_outlined
                        : Icons.pending_actions_outlined,
                    color: group.verified
                        ? RefereeColors.championshipGold
                        : RefereeColors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    group.verified ? 'Da xac thuc' : 'Cho xac thuc',
                    style: TextStyle(
                      color: group.verified
                          ? RefereeColors.championshipGold
                          : RefereeColors.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                group.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (group.meta.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  group.meta,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.65)),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.section),
        for (final finisher in group.finishers) ...[
          _LeaderboardRow(finisher: finisher),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({required this.finisher});

  final SpectatorResultFinisher finisher;

  @override
  Widget build(BuildContext context) {
    final isWinner = finisher.rank == 1;
    final owner = finisher.ownerUsername.trim().isEmpty
        ? spectatorPlaceholder
        : finisher.ownerUsername;

    return SpectatorGlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isWinner
                  ? RefereeColors.championshipGold
                  : Colors.white.withValues(alpha: 0.05),
              border: isWinner
                  ? null
                  : Border.all(color: RefereeColors.outlineVariant),
            ),
            child: Text(
              finisher.rank <= 0 ? spectatorPlaceholder : '${finisher.rank}',
              style: TextStyle(
                color: isWinner ? RefereeColors.background : Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _fallback(finisher.horseName),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                _MetaLine(
                  label: 'Jockey',
                  value: _fallback(finisher.jockeyName),
                ),
                _MetaLine(label: 'Owner', value: owner),
                _MetaLine(
                  label: 'Trang thai',
                  value: _fallback(finisher.status),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _fallback(finisher.time),
            textAlign: TextAlign.right,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isWinner
                  ? RefereeColors.championshipGold
                  : RefereeColors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text(
        '$label: $value',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
      ),
    );
  }
}

class _LeaderboardLoadingState extends StatelessWidget {
  const _LeaderboardLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 64),
      child: Center(
        child: CircularProgressIndicator(color: RefereeColors.championshipGold),
      ),
    );
  }
}

class _LeaderboardErrorState extends StatelessWidget {
  const _LeaderboardErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SpectatorGlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
          ),
          const SizedBox(height: 16),
          OutlinedButton(onPressed: onRetry, child: const Text('Thu lai')),
        ],
      ),
    );
  }
}

class _LeaderboardEmptyState extends StatelessWidget {
  const _LeaderboardEmptyState();

  @override
  Widget build(BuildContext context) {
    return SpectatorGlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(
            Icons.emoji_events_outlined,
            color: RefereeColors.championshipGold.withValues(alpha: 0.8),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Chua co ket qua cho cuoc dua nay.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.75)),
            ),
          ),
        ],
      ),
    );
  }
}

String _fallback(String value) {
  final text = value.trim();
  return text.isEmpty ? spectatorPlaceholder : text;
}
