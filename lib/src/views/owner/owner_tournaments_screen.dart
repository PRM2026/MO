import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../models/tournament_list_item.dart';
import '../../viewmodels/owner_tournaments_viewmodel.dart';
import '../../widgets/owner/owner_app_bar.dart';
import '../../widgets/owner/owner_dashboard_widgets.dart';
import '../../widgets/owner/owner_tournament_widgets.dart';
import 'owner_tournament_detail_screen.dart';

class OwnerTournamentsScreen extends StatefulWidget {
  const OwnerTournamentsScreen({super.key, this.onProfileTap});

  final VoidCallback? onProfileTap;

  @override
  State<OwnerTournamentsScreen> createState() => _OwnerTournamentsScreenState();
}

class _OwnerTournamentsScreenState extends State<OwnerTournamentsScreen> {
  late final OwnerTournamentsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = OwnerTournamentsViewModel();
    _viewModel.addListener(_onChanged);
    _viewModel.loadTournaments();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  void _openTournamentDetail(TournamentListItem tournament) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => OwnerTournamentDetailScreen(
          tournamentId: tournament.id,
          tournamentName: tournament.title,
          profileImageUrl: _viewModel.profileImageUrl,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onChanged);
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tournaments = _viewModel.tournaments;

    return Scaffold(
      backgroundColor: RefereeColors.background,
      appBar: OwnerAppBar(
        titleOverride: 'Giải Đấu',
        profileImageUrl: _viewModel.profileImageUrl,
        onProfileTap: widget.onProfileTap,
      ),
      body: OwnerPortalBackground(
        child: _viewModel.isLoading && tournaments.isEmpty
            ? const Center(
                child: CircularProgressIndicator(
                  color: RefereeColors.championshipGold,
                ),
              )
            : RefreshIndicator(
                color: RefereeColors.championshipGold,
                onRefresh: _viewModel.refreshTournaments,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.md,
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
                                OwnerTournamentFilterChips(
                                  selected: _viewModel.selectedFilter,
                                  onSelected: _viewModel.selectFilter,
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                if (_viewModel.errorMessage != null &&
                                    tournaments.isEmpty)
                                  _ErrorState(
                                    message: _viewModel.errorMessage!,
                                    onRetry: _viewModel.loadTournaments,
                                  )
                                else
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      final width = constraints.maxWidth;
                                      final crossAxisCount = width >= 640
                                          ? 2
                                          : 1;

                                      return GridView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: crossAxisCount,
                                              crossAxisSpacing: 24,
                                              mainAxisSpacing: 24,
                                              childAspectRatio:
                                                  crossAxisCount == 1
                                                  ? 0.68
                                                  : 0.58,
                                            ),
                                        itemCount: tournaments.length,
                                        itemBuilder: (context, index) {
                                          final tournament = tournaments[index];
                                          return OwnerTournamentGridCard(
                                            tournament: tournament,
                                            onPrimaryAction: () =>
                                                _openTournamentDetail(
                                                  tournament,
                                                ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                if (!_viewModel.isLoading &&
                                    tournaments.isEmpty &&
                                    _viewModel.errorMessage == null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 24),
                                    child: Text(
                                      _viewModel.selectedFilter !=
                                              OwnerTournamentFilter.all
                                          ? 'Không có giải đấu phù hợp bộ lọc.'
                                          : 'Không có giải đấu nào.',
                                      textAlign: TextAlign.center,
                                      style: AppTypography.bodyMd(
                                        RefereeColors.onSurfaceVariant,
                                      ),
                                    ),
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

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMd(RefereeColors.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            TextButton(onPressed: onRetry, child: const Text('Thử lại')),
          ],
        ),
      ),
    );
  }
}
