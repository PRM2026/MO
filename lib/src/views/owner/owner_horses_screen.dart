import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../models/owner_horse_item.dart';
import '../../utils/app_toast.dart';
import '../../viewmodels/owner_horses_viewmodel.dart';
import '../../widgets/owner/owner_app_bar.dart';
import '../../widgets/owner/owner_dashboard_widgets.dart';
import '../../widgets/owner/owner_horse_widgets.dart';

class OwnerHorsesScreen extends StatefulWidget {
  const OwnerHorsesScreen({super.key, this.viewModel, this.onProfileTap});

  final OwnerHorsesViewModel? viewModel;
  final VoidCallback? onProfileTap;

  @override
  State<OwnerHorsesScreen> createState() => _OwnerHorsesScreenState();
}

class _OwnerHorsesScreenState extends State<OwnerHorsesScreen> {
  late final OwnerHorsesViewModel _viewModel;
  late final bool _ownsViewModel;
  late final TextEditingController _searchController;
  bool _showSearchBar = false;

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _viewModel = widget.viewModel ?? OwnerHorsesViewModel();
    _searchController = TextEditingController();
    _viewModel.addListener(_onChanged);
    _viewModel.loadHorses();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  void _toggleSearch() {
    setState(() {
      _showSearchBar = !_showSearchBar;
      if (!_showSearchBar) {
        _searchController.clear();
        _viewModel.updateSearch('');
      }
    });
  }

  void _showFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: RefereeColors.portalSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Lọc ngựa',
                  style: AppTypography.headlineSm(RefereeColors.onSurface),
                ),
                const SizedBox(height: 12),
                for (final filter in OwnerHorseFilter.values)
                  ListTile(
                    title: Text(
                      filter.label,
                      style: AppTypography.bodyMd(RefereeColors.onSurface),
                    ),
                    trailing: _viewModel.selectedFilter == filter
                        ? const Icon(
                            Icons.check,
                            color: RefereeColors.championshipGold,
                          )
                        : null,
                    onTap: () {
                      _viewModel.selectFilter(filter);
                      Navigator.pop(context);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleAddHorse() {
    AppToast.showSuccess(
      context,
      'Tính năng thêm ngựa',
      subtitle: 'Đang được phát triển.',
    );
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
    final horses = _viewModel.filteredHorses;

    return Scaffold(
      backgroundColor: RefereeColors.background,
      appBar: OwnerAppBar(
        titleOverride: 'Danh Sách Ngựa',
        profileImageUrl: _viewModel.profileImageUrl,
        onProfileTap: widget.onProfileTap,
        showSearchAction: true,
        onSearchTap: _toggleSearch,
      ),
      floatingActionButton: _showSearchBar
          ? null
          : FloatingActionButton(
              onPressed: _showFilterSheet,
              backgroundColor: RefereeColors.championshipGold,
              foregroundColor: RefereeColors.onTertiary,
              child: const Icon(Icons.tune),
            ),
      body: OwnerPortalBackground(
        child: Column(
          children: [
            if (_showSearchBar)
              OwnerHorseSearchBar(
                controller: _searchController,
                onChanged: _viewModel.updateSearch,
                onClose: _toggleSearch,
              ),
            Expanded(
              child: _viewModel.isLoading && _viewModel.horses.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: RefereeColors.championshipGold,
                      ),
                    )
                  : RefreshIndicator(
                      color: RefereeColors.championshipGold,
                      onRefresh: _viewModel.loadHorses,
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
                                  constraints: const BoxConstraints(
                                    maxWidth: 1280,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      OwnerHorseFilterChips(
                                        selected: _viewModel.selectedFilter,
                                        onSelected: _viewModel.selectFilter,
                                      ),
                                      const SizedBox(height: AppSpacing.lg),
                                      if (_viewModel.loadError != null)
                                        _ErrorState(
                                          message: _viewModel.loadError!,
                                          onRetry: _viewModel.loadHorses,
                                        )
                                      else
                                        LayoutBuilder(
                                          builder: (context, constraints) {
                                            final width = constraints.maxWidth;
                                            final crossAxisCount = width >= 960
                                                ? 3
                                                : width >= 640
                                                ? 2
                                                : 1;

                                            final itemCount = horses.length + 1;

                                            return GridView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              gridDelegate:
                                                  SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount:
                                                        crossAxisCount,
                                                    crossAxisSpacing: 16,
                                                    mainAxisSpacing: 16,
                                                    childAspectRatio:
                                                        crossAxisCount == 1
                                                        ? 0.56
                                                        : 0.52,
                                                  ),
                                              itemCount: itemCount,
                                              itemBuilder: (context, index) {
                                                if (index == horses.length) {
                                                  return OwnerAddHorseCard(
                                                    onTap: _handleAddHorse,
                                                  );
                                                }

                                                return OwnerHorseGridCard(
                                                  horse: horses[index],
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      if (!_viewModel.isLoading &&
                                          _viewModel.loadError == null &&
                                          horses.isEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 24,
                                          ),
                                          child: Text(
                                            _viewModel.searchQuery.isNotEmpty ||
                                                    _viewModel.selectedFilter !=
                                                        OwnerHorseFilter.all
                                                ? 'Không tìm thấy ngựa phù hợp.'
                                                : 'Chưa có ngựa nào trong danh sách.',
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
          ],
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
