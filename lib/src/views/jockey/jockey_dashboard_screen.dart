import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/referee_colors.dart';
import '../../viewmodels/jockey_dashboard_viewmodel.dart';
import '../../widgets/jockey/jockey_app_bar.dart';
import '../../widgets/jockey/jockey_dashboard_widgets.dart';

class JockeyDashboardScreen extends StatefulWidget {
  const JockeyDashboardScreen({super.key, this.viewModel});

  final JockeyDashboardViewModel? viewModel;

  @override
  State<JockeyDashboardScreen> createState() => _JockeyDashboardScreenState();
}

class _JockeyDashboardScreenState extends State<JockeyDashboardScreen> {
  late final JockeyDashboardViewModel _viewModel;
  late final bool _ownsViewModel;

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _viewModel = widget.viewModel ?? JockeyDashboardViewModel();
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
                onRefresh: _viewModel.loadDashboard,
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
                                JockeyWelcomeHeader(
                                  greeting: data!.greeting,
                                  jockeyName: data.jockeyName,
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                JockeyStatsGrid(stats: data.stats),
                                const SizedBox(height: AppSpacing.lg),
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final isWide = constraints.maxWidth >= 960;

                                    if (isWide) {
                                      return Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 8,
                                            child: JockeyRecentResultsSection(
                                              results: data.recentResults,
                                            ),
                                          ),
                                          const SizedBox(width: AppSpacing.lg),
                                          Expanded(
                                            flex: 4,
                                            child: JockeyMotivationCard(
                                              quote: data.motivationQuote,
                                              imageUrl: data.motivationImageUrl,
                                            ),
                                          ),
                                        ],
                                      );
                                    }

                                    return Column(
                                      children: [
                                        JockeyRecentResultsSection(
                                          results: data.recentResults,
                                        ),
                                        const SizedBox(height: AppSpacing.lg),
                                        JockeyMotivationCard(
                                          quote: data.motivationQuote,
                                          imageUrl: data.motivationImageUrl,
                                        ),
                                      ],
                                    );
                                  },
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
