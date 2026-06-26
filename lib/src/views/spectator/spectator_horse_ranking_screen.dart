import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/referee_colors.dart';
import '../../models/spectator_models.dart';
import '../../viewmodels/spectator_horse_ranking_viewmodel.dart';
import '../../widgets/news/news_network_image.dart';
import '../../widgets/spectator/spectator_app_bar.dart';
import '../../widgets/spectator/spectator_glass_card.dart';

class SpectatorHorseRankingScreen extends StatefulWidget {
  const SpectatorHorseRankingScreen({super.key, this.viewModel});

  final SpectatorHorseRankingViewModel? viewModel;

  @override
  State<SpectatorHorseRankingScreen> createState() =>
      _SpectatorHorseRankingScreenState();
}

class _SpectatorHorseRankingScreenState
    extends State<SpectatorHorseRankingScreen> {
  late final SpectatorHorseRankingViewModel _viewModel;
  late final bool _ownsViewModel;

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _viewModel = widget.viewModel ?? SpectatorHorseRankingViewModel();
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
        return Scaffold(
          backgroundColor: RefereeColors.background,
          appBar: const SpectatorAppBar(
            titleOverride: 'Chien ma',
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
              const _HorseRankingHero(),
              const SizedBox(height: AppSpacing.section),
              if (_viewModel.isLoading)
                const _HorseRankingLoadingState()
              else if (_viewModel.errorMessage != null)
                _HorseRankingErrorState(
                  message: _viewModel.errorMessage!,
                  onRetry: _viewModel.retry,
                )
              else if (_viewModel.horses.isEmpty)
                const _HorseRankingEmptyState()
              else
                for (final horse in _viewModel.horses) ...[
                  _HorseRankingCard(horse: horse),
                  const SizedBox(height: 12),
                ],
            ],
          ),
        );
      },
    );
  }
}

class _HorseRankingHero extends StatelessWidget {
  const _HorseRankingHero();

  @override
  Widget build(BuildContext context) {
    return SpectatorGlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: RefereeColors.championshipGold.withValues(alpha: 0.14),
              border: Border.all(
                color: RefereeColors.championshipGold.withValues(alpha: 0.28),
              ),
            ),
            child: const Icon(
              Icons.pets_outlined,
              color: RefereeColors.championshipGold,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bang xep hang ngua',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Du lieu public tu API /horses/rankings',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HorseRankingCard extends StatelessWidget {
  const _HorseRankingCard({required this.horse});

  final SpectatorFeaturedHorse horse;

  @override
  Widget build(BuildContext context) {
    final isTopRank = horse.rank == 1;

    return SpectatorGlassCard(
      padding: const EdgeInsets.all(14),
      accentBorder: isTopRank,
      accentColor: RefereeColors.championshipGold,
      child: Row(
        children: [
          SizedBox(
            width: 72,
            height: 72,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: NewsNetworkImage(imageUrl: horse.imageUrl),
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isTopRank
                  ? RefereeColors.championshipGold
                  : Colors.white.withValues(alpha: 0.06),
              border: isTopRank
                  ? null
                  : Border.all(color: RefereeColors.outlineVariant),
            ),
            child: Text(
              horse.rank <= 0 ? spectatorPlaceholder : '#${horse.rank}',
              style: TextStyle(
                color: isTopRank ? RefereeColors.background : Colors.white,
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
                  horse.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                _MetaLine(label: 'Rider', value: horse.rider),
                _MetaLine(label: 'Win rate', value: horse.winRateLabel),
              ],
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
    final display = value.trim().isEmpty ? spectatorPlaceholder : value;

    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text(
        '$label: $display',
        style: TextStyle(color: Colors.white.withValues(alpha: 0.62)),
      ),
    );
  }
}

class _HorseRankingLoadingState extends StatelessWidget {
  const _HorseRankingLoadingState();

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

class _HorseRankingErrorState extends StatelessWidget {
  const _HorseRankingErrorState({required this.message, required this.onRetry});

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

class _HorseRankingEmptyState extends StatelessWidget {
  const _HorseRankingEmptyState();

  @override
  Widget build(BuildContext context) {
    return SpectatorGlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            Icons.pets_outlined,
            color: RefereeColors.championshipGold.withValues(alpha: 0.8),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Chua co bang xep hang ngua.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.75)),
            ),
          ),
        ],
      ),
    );
  }
}
