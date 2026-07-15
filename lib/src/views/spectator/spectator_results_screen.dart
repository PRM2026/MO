import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/referee_colors.dart';
import '../../models/spectator_models.dart';
import '../../viewmodels/spectator_results_viewmodel.dart';
import '../../widgets/spectator/spectator_app_bar.dart';
import '../../widgets/spectator/spectator_glass_card.dart';
import '../../widgets/spectator/spectator_results_widgets.dart';

class SpectatorResultsScreen extends StatefulWidget {
  const SpectatorResultsScreen({
    super.key,
    this.onProfileTap,
    this.onLeaderboardTap,
    this.viewModel,
  });

  final VoidCallback? onProfileTap;
  final ValueChanged<SpectatorResultGroup>? onLeaderboardTap;
  final SpectatorResultsViewModel? viewModel;

  @override
  State<SpectatorResultsScreen> createState() => _SpectatorResultsScreenState();
}

class _SpectatorResultsScreenState extends State<SpectatorResultsScreen> {
  late final SpectatorResultsViewModel _viewModel;
  late final bool _ownsViewModel;
  SpectatorResultCategory _filter = SpectatorResultCategory.all;

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _viewModel = widget.viewModel ?? SpectatorResultsViewModel();
    _viewModel.load();
  }

  @override
  void dispose() {
    if (_ownsViewModel) {
      _viewModel.dispose();
    }
    super.dispose();
  }

  List<SpectatorResultGroup> get _visibleResults {
    return switch (_filter) {
      SpectatorResultCategory.all => _viewModel.groups,
      SpectatorResultCategory.verified =>
        _viewModel.groups
            .where((group) => group.verified)
            .toList(growable: false),
      SpectatorResultCategory.recent =>
        _viewModel.groups
            .where((group) => group.category == SpectatorResultCategory.recent)
            .toList(growable: false),
      _ => _viewModel.groups,
    };
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
        final visibleResults = _visibleResults;

        return Scaffold(
          backgroundColor: RefereeColors.background,
          appBar: SpectatorAppBar(
            titleOverride: 'Ket qua',
            onProfileTap: widget.onProfileTap,
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.lg,
              AppSpacing.screenPadding,
              120,
            ),
            children: [
              const SpectatorResultsHero(),
              const SizedBox(height: AppSpacing.section),
              SpectatorResultsFilterBar(
                selected: _filter,
                onSelected: (filter) => setState(() => _filter = filter),
              ),
              const SizedBox(height: AppSpacing.section),
              if (_viewModel.isLoading)
                const _ResultsLoadingState()
              else if (_viewModel.errorMessage != null)
                _ResultsErrorState(
                  message: _viewModel.errorMessage!,
                  onRetry: _viewModel.retry,
                )
              else if (visibleResults.isEmpty)
                _ResultsEmptyState(filter: _filter)
              else
                for (final group in visibleResults) ...[
                  SpectatorRaceResultCard(
                    group: group,
                    onLeaderboardTap: widget.onLeaderboardTap == null
                        ? null
                        : () => widget.onLeaderboardTap!(group),
                  ),
                  const SizedBox(height: 16),
                ],
            ],
          ),
        );
      },
    );
  }
}

class _ResultsLoadingState extends StatelessWidget {
  const _ResultsLoadingState();

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

class _ResultsErrorState extends StatelessWidget {
  const _ResultsErrorState({required this.message, required this.onRetry});

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

class _ResultsEmptyState extends StatelessWidget {
  const _ResultsEmptyState({required this.filter});

  final SpectatorResultCategory filter;

  @override
  Widget build(BuildContext context) {
    final message = switch (filter) {
      SpectatorResultCategory.verified => 'Chua co ket qua da xac thuc tu API.',
      SpectatorResultCategory.recent => 'Chua co ket qua gan day.',
      _ => 'Chua co ket qua dua nao.',
    };

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
              message,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.75)),
            ),
          ),
        ],
      ),
    );
  }
}
