import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../models/owner_tournament_detail.dart';
import '../../routes/app_routes.dart';
import '../../utils/app_toast.dart';
import '../../viewmodels/owner_tournament_detail_viewmodel.dart';
import '../../widgets/owner/owner_app_bar.dart';
import '../../widgets/owner/owner_dashboard_widgets.dart';
import '../../widgets/owner/owner_tournament_detail_widgets.dart';

class OwnerTournamentDetailScreen extends StatefulWidget {
  const OwnerTournamentDetailScreen({
    super.key,
    required this.tournamentId,
    required this.tournamentName,
    this.profileImageUrl,
  });

  final String tournamentId;
  final String tournamentName;
  final String? profileImageUrl;

  @override
  State<OwnerTournamentDetailScreen> createState() =>
      _OwnerTournamentDetailScreenState();
}

class _OwnerTournamentDetailScreenState
    extends State<OwnerTournamentDetailScreen> {
  late final OwnerTournamentDetailViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = OwnerTournamentDetailViewModel(
      tournamentId: widget.tournamentId,
    );
    _viewModel.addListener(_onChanged);
    _viewModel.loadDetail();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _openInviteJockey(
    OwnerTournamentDetail detail,
    OwnerTournamentRace race,
  ) async {
    final changed = await AppRoutes.openOwnerCreateJockeyInvitation(
      context,
      initialRaceId: race.id,
      initialRaceName: race.name,
      initialTournamentId: detail.id,
      initialTournamentName: detail.name,
    );
    if (!mounted || changed != true) return;
    AppToast.showSuccess(context, 'Đã tạo lời mời jockey.');
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onChanged);
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detail = _viewModel.detail;

    return Scaffold(
      backgroundColor: RefereeColors.background,
      appBar: OwnerAppBar(
        showBack: true,
        titleOverride: widget.tournamentName,
        profileImageUrl: widget.profileImageUrl,
      ),
      body: OwnerPortalBackground(
        child: _viewModel.isLoading && detail == null
            ? const Center(
                child: CircularProgressIndicator(
                  color: RefereeColors.championshipGold,
                ),
              )
            : detail == null
            ? RefreshIndicator(
                color: RefereeColors.championshipGold,
                onRefresh: _viewModel.refresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    _DetailError(
                      message:
                          _viewModel.errorMessage ??
                          'Không thể tải chi tiết giải đấu.',
                      onRetry: _viewModel.loadDetail,
                    ),
                  ],
                ),
              )
            : DefaultTabController(
                length: 2,
                child: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) => [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.md,
                        AppSpacing.md,
                        0,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 960),
                            child: OwnerTournamentDetailHero(detail: detail),
                          ),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppSpacing.lg),
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _TournamentTabsDelegate(),
                    ),
                  ],
                  body: TabBarView(
                    children: [
                      _InformationTab(
                        detail: detail,
                        onRefresh: _viewModel.refresh,
                      ),
                      _RacesTab(
                        detail: detail,
                        onRefresh: _viewModel.refresh,
                        onInviteJockey: (race) =>
                            _openInviteJockey(detail, race),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _InformationTab extends StatelessWidget {
  const _InformationTab({required this.detail, required this.onRefresh});

  final OwnerTournamentDetail detail;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: RefereeColors.championshipGold,
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.contentBottomPadding(context),
        ),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  OwnerTournamentOverview(detail: detail),
                  const SizedBox(height: AppSpacing.lg),
                  OwnerTournamentTextSection(
                    title: 'Giới thiệu',
                    content: detail.description,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  OwnerTournamentTextSection(
                    title: 'Thể lệ giải đấu',
                    content: detail.rules,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RacesTab extends StatelessWidget {
  const _RacesTab({
    required this.detail,
    required this.onRefresh,
    required this.onInviteJockey,
  });

  final OwnerTournamentDetail detail;
  final Future<void> Function() onRefresh;
  final ValueChanged<OwnerTournamentRace> onInviteJockey;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: RefereeColors.championshipGold,
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.contentBottomPadding(context),
        ),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: OwnerTournamentRacesSection(
                races: detail.races,
                tournamentStatus: detail.status,
                onInviteJockey: onInviteJockey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TournamentTabsDelegate extends SliverPersistentHeaderDelegate {
  static const double _height = 56;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: RefereeColors.background,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: TabBar(
            indicatorColor: RefereeColors.championshipGold,
            indicatorWeight: 3,
            labelColor: RefereeColors.championshipGold,
            unselectedLabelColor: RefereeColors.onSurfaceVariant,
            dividerColor: Colors.white.withValues(alpha: 0.1),
            labelStyle: AppTypography.labelCaps(
              RefereeColors.championshipGold,
            ).copyWith(fontSize: 13),
            unselectedLabelStyle: AppTypography.labelCaps(
              RefereeColors.onSurfaceVariant,
            ).copyWith(fontSize: 13),
            tabs: const [
              Tab(text: 'Thông tin & Luật lệ'),
              Tab(text: 'Các cuộc đua'),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _TournamentTabsDelegate oldDelegate) => false;
}

class _DetailError extends StatelessWidget {
  const _DetailError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 72),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: RefereeColors.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypography.bodyMd(RefereeColors.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          OutlinedButton(onPressed: onRetry, child: const Text('Thử lại')),
        ],
      ),
    );
  }
}
