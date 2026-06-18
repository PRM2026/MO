import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/referee_colors.dart';
import '../../routes/app_routes.dart';
import '../../utils/app_toast.dart';
import '../../viewmodels/owner_profile_viewmodel.dart';
import '../../widgets/owner/owner_app_bar.dart';
import '../../widgets/owner/owner_dashboard_widgets.dart';
import '../../widgets/owner/owner_profile_widgets.dart';

class OwnerProfileScreen extends StatefulWidget {
  const OwnerProfileScreen({super.key, this.viewModel});

  final OwnerProfileViewModel? viewModel;

  @override
  State<OwnerProfileScreen> createState() => _OwnerProfileScreenState();
}

class _OwnerProfileScreenState extends State<OwnerProfileScreen> {
  late final OwnerProfileViewModel _viewModel;
  late final bool _ownsViewModel;

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _viewModel = widget.viewModel ?? OwnerProfileViewModel();
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
      AppRoutes.openOwnerChangePassword(
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
      appBar: OwnerAppBar(
        titleOverride: 'Hồ sơ',
        profileImageUrl: data?.avatarUrl,
        profileInteractive: false,
      ),
      body: OwnerPortalBackground(
        child: _viewModel.isLoading && data == null
            ? const Center(
                child: CircularProgressIndicator(
                  color: RefereeColors.championshipGold,
                ),
              )
            : data == null
            ? RefreshIndicator(
                color: RefereeColors.championshipGold,
                onRefresh: _viewModel.refreshData,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    _ProfileErrorState(
                      message:
                          _viewModel.errorMessage ??
                          'Không thể tải hồ sơ chủ ngựa.',
                      onRetry: _viewModel.refreshData,
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                color: RefereeColors.championshipGold,
                onRefresh: _viewModel.refreshData,
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            OwnerProfileHeader(profile: data),
                            const SizedBox(height: AppSpacing.lg),
                            OwnerProfileSettingsCard(
                              settings: data.settings,
                              onItemTap: (item) =>
                                  _handleSettingTap(item.title),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            OwnerProfileLogoutButton(
                              isLoading: _viewModel.isLoggingOut,
                              onPressed: _handleLogout,
                            ),
                          ],
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

class _ProfileErrorState extends StatelessWidget {
  const _ProfileErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 96, horizontal: 24),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: RefereeColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextButton(onPressed: onRetry, child: const Text('Thử lại')),
        ],
      ),
    );
  }
}
