import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/referee_colors.dart';
import '../../routes/app_routes.dart';
import '../../utils/app_toast.dart';
import '../../viewmodels/referee_profile_viewmodel.dart';
import '../../widgets/referee/referee_ambient_background.dart';
import '../../widgets/referee/referee_app_bar.dart';
import '../../widgets/referee/referee_profile_widgets.dart';

class RefereeProfileScreen extends StatefulWidget {
  const RefereeProfileScreen({super.key, this.viewModel});

  final RefereeProfileViewModel? viewModel;

  @override
  State<RefereeProfileScreen> createState() => _RefereeProfileScreenState();
}

class _RefereeProfileScreenState extends State<RefereeProfileScreen> {
  late final RefereeProfileViewModel _viewModel;
  late final bool _ownsViewModel;

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _viewModel = widget.viewModel ?? RefereeProfileViewModel();
    _viewModel.addListener(_onChanged);
    _viewModel.loadData();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _handleLogout() async {
    final success = await _viewModel.logout();
    if (!mounted || !success) return;

    AppToast.showSuccess(context, 'Đã đăng xuất');
    AppRoutes.openAfterLogout(context);
  }

  void _handleSettingTap(String title) {
    if (title == 'Bảo mật & Mật khẩu') {
      AppRoutes.openRefereeChangePassword(
        context,
        profileImageUrl: _viewModel.data?.avatarUrl,
      );
      return;
    }
    AppToast.showSuccess(context, 'Đang mở $title');
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
      appBar: RefereeAppBar(
        showBack: true,
        profileImageUrl: data?.avatarUrl,
        profileInteractive: false,
      ),
      body: RefereeAmbientBackground(
        child: _viewModel.isLoading && data == null
            ? const Center(
                child: CircularProgressIndicator(color: RefereeColors.tertiary),
              )
            : RefreshIndicator(
                color: RefereeColors.tertiary,
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                RefereeProfileHeader(profile: data!),
                                const SizedBox(height: AppSpacing.lg),
                                RefereeProfileStatsGrid(stats: data.stats),
                                const SizedBox(height: AppSpacing.lg),
                                RefereeProfileSettingsCard(
                                  settings: data.settings,
                                  onItemTap: (item) =>
                                      _handleSettingTap(item.title),
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                RefereeProfileLogoutButton(
                                  isLoading: _viewModel.isLoggingOut,
                                  onPressed: _handleLogout,
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
