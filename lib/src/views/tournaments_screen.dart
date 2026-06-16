import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';
import '../constants/tournament_colors.dart';
import '../constants/app_theme_tokens.dart';
import '../viewmodels/tournaments_viewmodel.dart';
import '../widgets/home/home_app_bar.dart';
import '../widgets/tournaments/tournament_list_card.dart';
import '../widgets/tournaments/tournament_search_bar.dart';

class TournamentsScreen extends StatefulWidget {
  const TournamentsScreen({super.key, this.viewModel});

  final TournamentsViewModel? viewModel;

  @override
  State<TournamentsScreen> createState() => _TournamentsScreenState();
}

class _TournamentsScreenState extends State<TournamentsScreen> {
  late final TournamentsViewModel _viewModel;
  late final TextEditingController _searchController;
  late final bool _ownsViewModel;

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _viewModel = widget.viewModel ?? TournamentsViewModel();
    _viewModel.addListener(_onChanged);
    _searchController = TextEditingController();
    _viewModel.loadTournaments();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onChanged);
    if (_ownsViewModel) _viewModel.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      primary: false,
      extendBody: false,
      backgroundColor: TournamentColors.surface,
      appBar: const HomeAppBar(),
      body: RefreshIndicator(
        onRefresh: _viewModel.refreshTournaments,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                  TournamentSearchBar(
                    controller: _searchController,
                    onChanged: _viewModel.updateSearch,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Tất cả các giải đấu',
                    style: AppTypography.headlineSm(TournamentColors.primary),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (_viewModel.isLoading && _viewModel.tournaments.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_viewModel.tournaments.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Text(
                        'Không tìm thấy giải đấu.',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMd(
                          TournamentColors.onSurfaceVariant,
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _viewModel.tournaments.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: AppSpacing.xl),
                      itemBuilder: (context, index) {
                        final tournament = _viewModel.tournaments[index];
                        return TournamentListCard(
                          tournament: tournament,
                          onTap: () {},
                        );
                      },
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
