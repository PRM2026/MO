import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/referee_colors.dart';
import '../../models/spectator_models.dart';
import '../../viewmodels/spectator_home_viewmodel.dart';
import '../../widgets/spectator/spectator_app_bar.dart';
import '../../widgets/spectator/spectator_glass_card.dart';
import '../../widgets/spectator/spectator_home_widgets.dart';

class SpectatorHomeScreen extends StatefulWidget {
  const SpectatorHomeScreen({
    super.key,
    this.onProfileTap,
    this.onRacesTap,
    this.onResultsTap,
    this.onViewAllRaces,
    this.viewModel,
  });

  final VoidCallback? onProfileTap;
  final VoidCallback? onRacesTap;
  final VoidCallback? onResultsTap;
  final VoidCallback? onViewAllRaces;
  final SpectatorHomeViewModel? viewModel;

  @override
  State<SpectatorHomeScreen> createState() => _SpectatorHomeScreenState();
}

class _SpectatorHomeScreenState extends State<SpectatorHomeScreen> {
  late final SpectatorHomeViewModel _viewModel;
  late final bool _ownsViewModel;

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _viewModel = widget.viewModel ?? SpectatorHomeViewModel();
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
        final data = _viewModel.data;
        final profile = data?.profile;
        final avatarUrl = profile?.avatarUrl.trim();

        return Scaffold(
          backgroundColor: RefereeColors.background,
          appBar: SpectatorAppBar(
            profileImageUrl: avatarUrl == null || avatarUrl.isEmpty
                ? null
                : avatarUrl,
            displayName: profile?.displayName ?? 'Khan gia',
            onProfileTap: widget.onProfileTap,
          ),
          body: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  AppSpacing.lg,
                  AppSpacing.screenPadding,
                  120,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (_viewModel.isLoading && data == null)
                      const _HomeLoadingState()
                    else if (_viewModel.errorMessage != null && data == null)
                      _HomeErrorState(
                        message: _viewModel.errorMessage!,
                        onRetry: _viewModel.retry,
                      )
                    else
                      ..._homeContent(data),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _homeContent(SpectatorHomeData? data) {
    return [
      if (data?.featuredEvent != null) ...[
        SpectatorHeroBanner(
          event: data!.featuredEvent!,
          onViewDetails: widget.onViewAllRaces,
        ),
        const SizedBox(height: AppSpacing.section),
      ] else ...[
        const _HomeEmptyHeroState(),
        const SizedBox(height: AppSpacing.section),
      ],
      SpectatorQuickActions(
        onScheduleTap: widget.onRacesTap,
        onHorsesTap: widget.onRacesTap,
        onResultsTap: widget.onResultsTap,
      ),
      const SizedBox(height: AppSpacing.section),
      SpectatorSectionHeader(
        title: 'Cuoc dua sap toi',
        actionLabel: 'Xem tat ca',
        onActionTap: widget.onViewAllRaces,
      ),
      const SizedBox(height: AppSpacing.lg),
      if (data?.upcomingRaces.isNotEmpty == true) ...[
        for (final race in data!.upcomingRaces) ...[
          SpectatorRaceListTile(race: race, onTap: widget.onRacesTap),
          const SizedBox(height: 12),
        ],
      ] else ...[
        const _HomeEmptyUpcomingRacesState(),
      ],
      const SizedBox(height: AppSpacing.section),
      const SpectatorSectionHeader(title: 'Chien ma noi bat'),
      const SizedBox(height: AppSpacing.lg),
      if (data?.featuredHorses.isNotEmpty == true)
        SpectatorHorizontalList(
          itemCount: data!.featuredHorses.length,
          itemBuilder: (context, index) {
            return SpectatorFeaturedHorseCard(
              horse: data.featuredHorses[index],
            );
          },
        )
      else
        const _HomeEmptyHorsesState(),
      const SizedBox(height: AppSpacing.section),
      const SpectatorSectionHeader(title: 'Ket qua gan day'),
      const SizedBox(height: AppSpacing.lg),
      if (data?.recentResults.isNotEmpty == true)
        SpectatorRecentResultsPanel(results: data!.recentResults)
      else
        const _HomeEmptyRecentResultsState(),
    ];
  }
}

class _HomeLoadingState extends StatelessWidget {
  const _HomeLoadingState();

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

class _HomeErrorState extends StatelessWidget {
  const _HomeErrorState({required this.message, required this.onRetry});

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

class _HomeEmptyHeroState extends StatelessWidget {
  const _HomeEmptyHeroState();

  @override
  Widget build(BuildContext context) {
    return SpectatorGlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            color: RefereeColors.championshipGold.withValues(alpha: 0.8),
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            'Chua co giai dau noi bat.',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Hay quay lai sau khi ban to chuc cong bo giai dau moi.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
          ),
        ],
      ),
    );
  }
}

class _HomeEmptyUpcomingRacesState extends StatelessWidget {
  const _HomeEmptyUpcomingRacesState();

  @override
  Widget build(BuildContext context) {
    return SpectatorGlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            Icons.calendar_month_outlined,
            color: RefereeColors.championshipGold.withValues(alpha: 0.8),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Chua co cuoc dua sap toi.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.75)),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeEmptyHorsesState extends StatelessWidget {
  const _HomeEmptyHorsesState();

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

class _HomeEmptyRecentResultsState extends StatelessWidget {
  const _HomeEmptyRecentResultsState();

  @override
  Widget build(BuildContext context) {
    return SpectatorGlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            Icons.emoji_events_outlined,
            color: RefereeColors.championshipGold.withValues(alpha: 0.8),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Chua co ket qua gan day.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.75)),
            ),
          ),
        ],
      ),
    );
  }
}
