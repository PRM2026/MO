import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../models/jockey_results_data.dart';
import '../../routes/app_routes.dart';
import '../../viewmodels/jockey_results_viewmodel.dart';
import '../../widgets/jockey/jockey_app_bar.dart';
import '../../widgets/jockey/jockey_dashboard_widgets.dart';
import '../../widgets/jockey/jockey_results_widgets.dart';
import '../../widgets/jockey/jockey_state_widgets.dart';

class JockeyResultsScreen extends StatefulWidget {
  const JockeyResultsScreen({super.key, this.viewModel, this.onRaceTap});

  final JockeyResultsViewModel? viewModel;
  final ValueChanged<JockeyRaceResultItem>? onRaceTap;

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

  void _openRace(JockeyRaceResultItem item) {
    final callback = widget.onRaceTap;
    if (callback != null) {
      callback(item);
      return;
    }

    if (item.hasResult) {
      AppRoutes.openJockeyRaceResults(
        context,
        raceId: item.raceId,
        tournamentId: item.tournamentId,
      );
      return;
    }
    AppRoutes.openJockeyRaceDetail(context, item.raceId);
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
      appBar: const JockeyAppBar(),
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
                            constraints: const BoxConstraints(maxWidth: 1120),
                            child: data == null
                                ? JockeyStateMessage(
                                    message:
                                        _viewModel.errorMessage ??
                                        'Chưa có dữ liệu kết quả.',
                                    onRetry: _viewModel.loadResults,
                                  )
                                : _ResultsContent(
                                    data: data,
                                    onRaceTap: _openRace,
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

class _ResultsContent extends StatelessWidget {
  const _ResultsContent({required this.data, required this.onRaceTap});

  final JockeyResultsData data;
  final ValueChanged<JockeyRaceResultItem> onRaceTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'THÀNH TÍCH JOCKEY',
          style: AppTypography.labelCaps(RefereeColors.tertiary),
        ),
        const SizedBox(height: 4),
        Text(
          'Kết quả và thanh toán',
          style: AppTypography.displayLg(
            RefereeColors.onSurface,
          ).copyWith(fontSize: 28),
        ),
        const SizedBox(height: AppSpacing.xl),
        JockeyResultsStatsGrid(stats: data.stats),
        const SizedBox(height: AppSpacing.xl),
        if (data.results.isEmpty)
          const JockeyStateMessage(
            message: 'Chưa có cuộc đua nào được phân công.',
          )
        else
          JockeyResultsHistorySection(
            results: data.results,
            onResultTap: onRaceTap,
          ),
        const SizedBox(height: AppSpacing.xl),
        if (data.prizes.isEmpty)
          const JockeyStateMessage(
            message: 'Chưa có khoản thưởng hoặc thù lao nào.',
          )
        else
          JockeyPrizePayoutSection(prizes: data.prizes),
      ],
    );
  }
}
