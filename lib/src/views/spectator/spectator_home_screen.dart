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
      ],
      SpectatorQuickActions(
        onScheduleTap: widget.onRacesTap,
        onHorsesTap: widget.onRacesTap,
        onResultsTap: widget.onResultsTap,
      ),
      if (data?.upcomingRaces.isNotEmpty == true) ...[
        const SizedBox(height: AppSpacing.section),
        SpectatorSectionHeader(
          title: 'Cuoc dua sap toi',
          actionLabel: 'Xem tat ca',
          onActionTap: widget.onViewAllRaces,
        ),
        const SizedBox(height: AppSpacing.lg),
        for (final race in data!.upcomingRaces) ...[
          SpectatorRaceListTile(race: race),
          const SizedBox(height: 12),
        ],
      ],
      if (data?.featuredHorses.isNotEmpty == true) ...[
        const SizedBox(height: AppSpacing.section),
        const SpectatorSectionHeader(title: 'Chien ma noi bat'),
        const SizedBox(height: AppSpacing.lg),
        SpectatorHorizontalList(
          itemCount: data!.featuredHorses.length,
          itemBuilder: (context, index) {
            return SpectatorFeaturedHorseCard(
              horse: data.featuredHorses[index],
            );
          },
        ),
      ],
      if (data?.recentResults.isNotEmpty == true) ...[
        const SizedBox(height: AppSpacing.section),
        const SpectatorSectionHeader(title: 'Ket qua gan day'),
        const SizedBox(height: AppSpacing.lg),
        SpectatorRecentResultsPanel(results: data!.recentResults),
      ],
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
