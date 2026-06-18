import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/referee_colors.dart';
import '../../routes/app_routes.dart';
import '../../utils/app_toast.dart';
import '../../viewmodels/jockey_profile_viewmodel.dart';
import '../../widgets/jockey/jockey_app_bar.dart';
import '../../widgets/jockey/jockey_dashboard_widgets.dart';
import '../../widgets/jockey/jockey_profile_widgets.dart';
import '../../widgets/jockey/jockey_state_widgets.dart';

class JockeyProfileScreen extends StatefulWidget {
  const JockeyProfileScreen({super.key, this.viewModel});

  final JockeyProfileViewModel? viewModel;

  @override
  State<JockeyProfileScreen> createState() => _JockeyProfileScreenState();
}

class _JockeyProfileScreenState extends State<JockeyProfileScreen> {
  late final JockeyProfileViewModel _viewModel;
  late final bool _ownsViewModel;

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _viewModel = widget.viewModel ?? JockeyProfileViewModel();
    _viewModel.addListener(_onChanged);
    _viewModel.loadData();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _handleLogout() async {
    final success = await _viewModel.logout();
    if (!mounted || !success) return;

    AppToast.showSuccess(context, 'Da dang xuat');
    AppRoutes.openAfterLogout(context);
  }

  void _handleChangePassword() {
    AppRoutes.openJockeyChangePassword(
      context,
      profileImageUrl: _viewModel.data?.avatarUrl,
    );
  }

  Future<void> _handleEditProfile() async {
    final profile = _viewModel.data;
    if (profile == null || profile.statusCode == 'SUSPENDED') return;

    final updated = await AppRoutes.openJockeyProfileEdit(context, profile);
    if (!mounted || updated == null) return;

    AppToast.showSuccess(context, 'Da cap nhat ho so jockey');
    await _viewModel.loadData();
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
      appBar: JockeyAppBar(
        showBack: true,
        showBrandTitle: false,
        profileImageUrl: data?.avatarUrl,
        profileInteractive: false,
      ),
      body: JockeySpeedlineBackground(
        child: _viewModel.isLoading && data == null
            ? const Center(
                child: CircularProgressIndicator(
                  color: RefereeColors.championshipGold,
                ),
              )
            : RefreshIndicator(
                color: RefereeColors.championshipGold,
                onRefresh: _viewModel.loadData,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.lg,
                        AppSpacing.md,
                        AppSpacing.xl,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1280),
                            child: data == null
                                ? JockeyStateMessage(
                                    message:
                                        _viewModel.errorMessage ??
                                        'Chua co du lieu ho so jockey.',
                                    onRetry: _viewModel.loadData,
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      JockeyProfileHeaderCard(profile: data),
                                      if (data.shouldShowReviewReason) ...[
                                        const SizedBox(height: AppSpacing.lg),
                                        JockeyProfileReviewCard(profile: data),
                                      ],
                                      const SizedBox(height: AppSpacing.lg),
                                      JockeyProfilePerformanceGrid(
                                        profile: data,
                                      ),
                                      const SizedBox(height: AppSpacing.lg),
                                      JockeyProfileInfoSection(profile: data),
                                      const SizedBox(height: AppSpacing.lg),
                                      JockeyRaceHistorySection(
                                        items: data.raceHistory,
                                      ),
                                      const SizedBox(height: AppSpacing.lg),
                                      JockeyProfileActionsCard(
                                        isLoggingOut: _viewModel.isLoggingOut,
                                        onEdit: data.statusCode == 'SUSPENDED'
                                            ? null
                                            : _handleEditProfile,
                                        onChangePassword: _handleChangePassword,
                                        onLogout: _handleLogout,
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
