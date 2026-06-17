import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../models/referee_dashboard_data.dart';
import '../../viewmodels/referee_dashboard_viewmodel.dart';
import '../../widgets/referee/referee_alert_banner.dart';
import '../../widgets/referee/referee_app_bar.dart';
import '../../widgets/referee/referee_race_card.dart';
import '../../widgets/referee/referee_stat_card.dart';

class RefereeDashboardScreen extends StatefulWidget {
  const RefereeDashboardScreen({super.key, this.viewModel});

  final RefereeDashboardViewModel? viewModel;

  @override
  State<RefereeDashboardScreen> createState() => _RefereeDashboardScreenState();
}

class _RefereeDashboardScreenState extends State<RefereeDashboardScreen> {
  late final RefereeDashboardViewModel _viewModel;
  late final bool _ownsViewModel;

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _viewModel = widget.viewModel ?? RefereeDashboardViewModel();
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
      appBar: RefereeAppBar(profileImageUrl: data?.profileImageUrl),
      body: _viewModel.isLoading && data == null
          ? const Center(
              child: CircularProgressIndicator(color: RefereeColors.tertiary),
            )
          : RefreshIndicator(
              color: RefereeColors.tertiary,
              onRefresh: _viewModel.loadDashboard,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
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
                        _WelcomeSection(
                          name: data!.refereeName,
                          message: data.welcomeMessage,
                        ),
                        const SizedBox(height: AppSpacing.section),
                        _StatsGrid(stats: data.stats),
                        if (data.showAlert) ...[
                          const SizedBox(height: AppSpacing.section),
                          RefereeAlertBanner(
                            title: data.alertTitle,
                            message: data.alertMessage,
                            onAction: () {},
                          ),
                        ],
                        if (data.races.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.section),
                          _RecentRacesSection(races: data.races),
                        ] else
                          Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.section),
                            child: Text(
                              'Chưa có cuộc đua sắp tới được giao.',
                              style: AppTypography.bodyMd(
                                RefereeColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _WelcomeSection extends StatelessWidget {
  const _WelcomeSection({required this.name, required this.message});

  final String name;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: AppTypography.displayLg(RefereeColors.onSurface),
            children: [
              const TextSpan(text: 'Chào trọng tài, '),
              TextSpan(
                text: name,
                style: AppTypography.displayLg(RefereeColors.tertiary).copyWith(
                  shadows: [
                    Shadow(
                      color: RefereeColors.tertiary.withValues(alpha: 0.4),
                      blurRadius: 15,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          style: AppTypography.bodyMd(RefereeColors.onSurfaceVariant)
              .copyWith(fontSize: 18, height: 28 / 18),
        ),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});

  final List<RefereeStatItem> stats;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 720 ? 4 : 2;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: stats.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: crossAxisCount == 4 ? 1.35 : 0.92,
          ),
          itemBuilder: (context, index) =>
              RefereeStatCard(stat: stats[index]),
        );
      },
    );
  }
}

class _RecentRacesSection extends StatelessWidget {
  const _RecentRacesSection({required this.races});

  final List<RefereeRaceItem> races;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Các lượt đua gần đây',
                style: AppTypography.headlineSm(RefereeColors.onSurface)
                    .copyWith(fontSize: 24, height: 32 / 24),
              ),
            ),
            TextButton.icon(
              onPressed: () {},
              iconAlignment: IconAlignment.end,
              icon: const Icon(
                Icons.chevron_right,
                size: 18,
                color: RefereeColors.tertiary,
              ),
              label: Text(
                'XEM TẤT CẢ',
                style: AppTypography.labelCaps(RefereeColors.tertiary),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 900) {
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: races.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  childAspectRatio: 0.72,
                ),
                itemBuilder: (context, index) => RefereeRaceCard(
                  race: races[index],
                  onAction: () {},
                ),
              );
            }

            return Column(
              children: [
                for (var i = 0; i < races.length; i++) ...[
                  RefereeRaceCard(race: races[i], onAction: () {}),
                  if (i < races.length - 1) const SizedBox(height: 24),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}
