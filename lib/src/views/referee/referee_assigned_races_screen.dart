import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../viewmodels/referee_assigned_races_viewmodel.dart';
import '../../widgets/referee/referee_app_bar.dart';
import '../../widgets/referee/referee_assigned_race_card.dart';
import '../../widgets/referee/referee_search_bar.dart';

class RefereeAssignedRacesScreen extends StatefulWidget {
  const RefereeAssignedRacesScreen({super.key, this.viewModel});

  final RefereeAssignedRacesViewModel? viewModel;

  @override
  State<RefereeAssignedRacesScreen> createState() =>
      _RefereeAssignedRacesScreenState();
}

class _RefereeAssignedRacesScreenState
    extends State<RefereeAssignedRacesScreen> {
  late final RefereeAssignedRacesViewModel _viewModel;
  late final TextEditingController _searchController;
  late final bool _ownsViewModel;

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _viewModel = widget.viewModel ?? RefereeAssignedRacesViewModel();
    _viewModel.addListener(_onChanged);
    _searchController = TextEditingController();
    _viewModel.loadRaces();
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
      backgroundColor: RefereeColors.background,
      appBar: RefereeAppBar(profileImageUrl: _viewModel.data?.profileImageUrl),
      body: _viewModel.isLoading && _viewModel.data == null
          ? const Center(
              child: CircularProgressIndicator(color: RefereeColors.tertiary),
            )
          : _viewModel.errorMessage != null && _viewModel.data == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Không thể tải danh sách cuộc đua từ máy chủ.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMd(
                        RefereeColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    FilledButton(
                      onPressed: _viewModel.loadRaces,
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              color: RefereeColors.tertiary,
              onRefresh: _viewModel.loadRaces,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenPadding,
                      AppSpacing.lg,
                      AppSpacing.screenPadding,
                      100,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        Text(
                          'Cuộc Đua Được Giao',
                          style: AppTypography.headlineSm(
                            RefereeColors.onSurface,
                          ).copyWith(fontSize: 24, height: 32 / 24),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _viewModel.data?.welcomeMessage ??
                              'Chào mừng trở lại, hãy kiểm tra các lịch trình điều hành được giao.',
                          style: AppTypography.bodyMd(
                            RefereeColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        RefereeSearchBar(
                          controller: _searchController,
                          onChanged: _viewModel.updateSearch,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        RefereeFilterChips(
                          selected: _viewModel.selectedFilter,
                          onSelected: _viewModel.updateFilter,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        if (_viewModel.filteredRaces.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 48),
                            child: Text(
                              'Không tìm thấy cuộc đua.',
                              textAlign: TextAlign.center,
                              style: AppTypography.bodyMd(
                                RefereeColors.onSurfaceVariant,
                              ),
                            ),
                          )
                        else
                          LayoutBuilder(
                            builder: (context, constraints) {
                              if (constraints.maxWidth >= 900) {
                                return GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _viewModel.filteredRaces.length,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        crossAxisSpacing: 24,
                                        mainAxisSpacing: 24,
                                        childAspectRatio: 0.68,
                                      ),
                                  itemBuilder: (context, index) =>
                                      RefereeAssignedRaceCard(
                                        race: _viewModel.filteredRaces[index],
                                      ),
                                );
                              }

                              if (constraints.maxWidth >= 600) {
                                return GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _viewModel.filteredRaces.length,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 16,
                                        mainAxisSpacing: 16,
                                        childAspectRatio: 0.72,
                                      ),
                                  itemBuilder: (context, index) =>
                                      RefereeAssignedRaceCard(
                                        race: _viewModel.filteredRaces[index],
                                      ),
                                );
                              }

                              return Column(
                                children: [
                                  for (
                                    var i = 0;
                                    i < _viewModel.filteredRaces.length;
                                    i++
                                  ) ...[
                                    RefereeAssignedRaceCard(
                                      race: _viewModel.filteredRaces[i],
                                    ),
                                    if (i < _viewModel.filteredRaces.length - 1)
                                      const SizedBox(height: 24),
                                  ],
                                ],
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
