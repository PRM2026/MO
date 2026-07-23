import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';
import '../routes/app_routes.dart';
import '../viewmodels/home_viewmodel.dart';
import '../widgets/home/cta_banner.dart';
import '../widgets/home/hero_banner.dart';
import '../widgets/home/home_app_bar.dart';
import '../widgets/home/home_bottom_nav.dart';
import '../widgets/home/horse_ranking_panel.dart';
import '../widgets/home/news_highlight_card.dart';
import '../widgets/home/section_header.dart';
import '../widgets/home/stat_metric_card.dart';
import '../widgets/home/tournament_card.dart';
import 'main_shell.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.viewModel});

  final HomeViewModel? viewModel;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeViewModel _viewModel;
  late final bool _ownsViewModel;

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _viewModel = widget.viewModel ?? HomeViewModel();
    _viewModel.addListener(_onChanged);
    _viewModel.loadUpcomingTournaments();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  void _openLogin() => AppRoutes.openLogin(context);

  void _openRegister() => AppRoutes.openRegister(context);

  void _openTournamentsTab() {
    MainShell.selectTab(context, HomeTab.tournaments);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onChanged);
    if (_ownsViewModel) {
      _viewModel.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      primary: false,
      extendBody: false,
      appBar: HomeAppBar(onLogin: _openLogin),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.lg,
              AppSpacing.screenPadding,
              AppSpacing.bottomNavClearance,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                HeroBanner(
                  imageUrl: _viewModel.heroImageUrl,
                  onViewTournaments: _openTournamentsTab,
                  onRegister: _openRegister,
                ),
                const SizedBox(height: AppSpacing.section),
                SectionHeader(
                  title: 'Giải đấu sắp tới',
                  actionLabel: 'Xem tất cả',
                  onActionTap: _openTournamentsTab,
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(height: 320, child: _buildTournamentCarousel()),
                const SizedBox(height: AppSpacing.section),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 720;
                    final rankings = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'Bảng xếp hạng'),
                        const SizedBox(height: AppSpacing.lg),
                        HorseRankingPanel(rankings: _viewModel.rankings),
                      ],
                    );
                    final stats = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'Thống kê hệ thống'),
                        const SizedBox(height: AppSpacing.lg),
                        StatMetricsGrid(metrics: _viewModel.stats),
                      ],
                    );

                    if (isWide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: rankings),
                          const SizedBox(width: AppSpacing.xl),
                          Expanded(child: stats),
                        ],
                      );
                    }

                    return Column(
                      children: [
                        rankings,
                        const SizedBox(height: AppSpacing.section),
                        stats,
                      ],
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.section),
                const SectionHeader(title: 'Tin tức nổi bật'),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  height: 96,
                  child: HorizontalCarousel(
                    itemCount: _viewModel.news.length,
                    itemBuilder: (context, index) =>
                        NewsHighlightCard(article: _viewModel.news[index]),
                  ),
                ),
                const SizedBox(height: AppSpacing.section),
                CtaBanner(onRegister: _openRegister, onLogin: _openLogin),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTournamentCarousel() {
    if (_viewModel.isLoadingTournaments &&
        _viewModel.upcomingTournaments.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_viewModel.upcomingTournaments.isEmpty) {
      return const Center(child: Text('Chưa có giải đấu sắp tới.'));
    }

    return HorizontalCarousel(
      itemCount: _viewModel.upcomingTournaments.length,
      itemBuilder: (context, index) =>
          TournamentCard(tournament: _viewModel.upcomingTournaments[index]),
    );
  }
}
