import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/referee_colors.dart';
import '../../viewmodels/owner_dashboard_viewmodel.dart';
import '../../widgets/owner/owner_app_bar.dart';
import '../../widgets/owner/owner_dashboard_widgets.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({
    super.key,
    this.viewModel,
    this.onProfileTap,
    this.onViewAllHorses,
    this.onViewTournament,
  });

  final OwnerDashboardViewModel? viewModel;
  final VoidCallback? onProfileTap;
  final VoidCallback? onViewAllHorses;
  final VoidCallback? onViewTournament;

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  late final OwnerDashboardViewModel _viewModel;
  late final bool _ownsViewModel;

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _viewModel = widget.viewModel ?? OwnerDashboardViewModel();
    _viewModel.addListener(_onChanged);
    _viewModel.loadDashboard();
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
      appBar: OwnerAppBar(
        profileImageUrl: data?.profileImageUrl,
        onProfileTap: widget.onProfileTap,
      ),
      body: OwnerPortalBackground(
        child: _viewModel.isLoading && data == null
            ? const Center(
                child: CircularProgressIndicator(
                  color: RefereeColors.championshipGold,
                ),
              )
            : data == null
            ? RefreshIndicator(
                color: RefereeColors.championshipGold,
                onRefresh: _viewModel.refreshDashboard,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    _DashboardErrorState(
                      message:
                          _viewModel.errorMessage ??
                          'Không thể tải dữ liệu tổng quan.',
                      onRetry: _viewModel.refreshDashboard,
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                color: RefereeColors.championshipGold,
                onRefresh: _viewModel.refreshDashboard,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.lg,
                        AppSpacing.md,
                        120,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (data.hero == null)
                              const OwnerDashboardEmptyHero()
                            else
                              OwnerHeroBanner(
                                hero: data.hero!,
                                onViewTournament: widget.onViewTournament,
                              ),
                            const SizedBox(height: AppSpacing.lg),
                            OwnerFeaturedHorsesSection(
                              horses: data.featuredHorses,
                              onViewAll: widget.onViewAllHorses,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            OwnerUpcomingRacesSection(
                              races: data.upcomingRaces,
                            ),
                          ],
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

class _DashboardErrorState extends StatelessWidget {
  const _DashboardErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 96, horizontal: 24),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: RefereeColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextButton(onPressed: onRetry, child: const Text('Thử lại')),
        ],
      ),
    );
  }
}
