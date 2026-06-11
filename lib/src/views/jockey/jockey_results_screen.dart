import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../viewmodels/jockey_results_viewmodel.dart';
import '../../widgets/jockey/jockey_app_bar.dart';
import '../../widgets/jockey/jockey_dashboard_widgets.dart';
import '../../widgets/jockey/jockey_results_widgets.dart';

class JockeyResultsScreen extends StatefulWidget {
  const JockeyResultsScreen({super.key, this.viewModel});

  final JockeyResultsViewModel? viewModel;

  @override
  State<JockeyResultsScreen> createState() => _JockeyResultsScreenState();
}

class _JockeyResultsScreenState extends State<JockeyResultsScreen> {
  late final JockeyResultsViewModel _viewModel;
  late final bool _ownsViewModel;

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _viewModel = widget.viewModel ?? JockeyResultsViewModel();
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
      appBar: JockeyAppBar(profileImageUrl: data?.profileImageUrl),
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
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1280),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'PORTAL QUẢN LÝ CAO CẤP',
                                      style: AppTypography.labelCaps(
                                        RefereeColors.tertiary,
                                      ).copyWith(letterSpacing: 1.2),
                                    ),
                                    Text(
                                      'Phân tích kết quả đua',
                                      style: AppTypography.displayLg(
                                        RefereeColors.onSurface,
                                      ).copyWith(fontSize: 28),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.xl),
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final isWide = constraints.maxWidth >= 960;

                                    final statsSection = Column(
                                      children: [
                                        JockeyResultsStatsGrid(
                                          stats: data!.stats,
                                        ),
                                        const SizedBox(height: 16),
                                        JockeyPerformanceChartCard(
                                          heights: data.chartHeights,
                                          trendLabel: data.chartTrendLabel,
                                        ),
                                      ],
                                    );

                                    if (isWide) {
                                      return Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 8,
                                            child: statsSection,
                                          ),
                                          const SizedBox(width: AppSpacing.lg),
                                          Expanded(
                                            flex: 4,
                                            child: JockeyFeaturedHorsePanel(
                                              horse: data.featuredHorse,
                                            ),
                                          ),
                                        ],
                                      );
                                    }

                                    return Column(
                                      children: [
                                        statsSection,
                                        const SizedBox(height: AppSpacing.lg),
                                        JockeyFeaturedHorsePanel(
                                          horse: data.featuredHorse,
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                const SizedBox(height: AppSpacing.xl),
                                JockeyResultsHistorySection(
                                  results: data!.results,
                                  totalResults: data.totalResults,
                                ),
                              ],
                            ),
                          ),
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
