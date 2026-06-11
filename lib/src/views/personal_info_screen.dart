import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../routes/app_routes.dart';
import '../utils/app_toast.dart';
import '../utils/role_utils.dart';
import '../viewmodels/personal_info_viewmodel.dart';
import '../widgets/home/home_app_bar.dart';
import '../widgets/personal_info/personal_info_widgets.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({
    super.key,
    this.viewModel,
    this.embedded = false,
  });

  final PersonalInfoViewModel? viewModel;
  final bool embedded;

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  late final PersonalInfoViewModel _viewModel;
  late final bool _ownsViewModel;
  bool _portalRedirectScheduled = false;

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _viewModel = widget.viewModel ?? PersonalInfoViewModel();
    _viewModel.addListener(_onChanged);
    _viewModel.loadData();
  }

  void _onChanged() {
    if (mounted) setState(() {});
    _schedulePortalRedirectIfNeeded();
  }

  void _schedulePortalRedirectIfNeeded() {
    if (_portalRedirectScheduled || _viewModel.isLoading || !_viewModel.isLoggedIn) {
      return;
    }

    final role = _viewModel.normalizedRole;
    if (role == null || !hasDedicatedPortal(role)) return;

    _portalRedirectScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      AppRoutes.openDedicatedPortal(context, role);
    });
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onChanged);
    if (_ownsViewModel) _viewModel.dispose();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    final success = await _viewModel.logout();
    if (!mounted || !success) return;
    _portalRedirectScheduled = false;
    AppToast.showSuccess(context, 'Đã đăng xuất');
    AppRoutes.openAfterLogout(context);
  }

  Widget _buildBody() {
    return _viewModel.isLoading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            color: AppColors.primary,
            onRefresh: _viewModel.loadData,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.screenPadding,
                    AppSpacing.lg,
                    AppSpacing.screenPadding,
                    widget.embedded
                        ? AppSpacing.contentBottomPadding(context)
                        : AppSpacing.bottomNavClearance,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 720),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            PersonalInfoHeaderCard(viewModel: _viewModel),
                            const SizedBox(height: AppSpacing.lg),
                            PersonalInfoDetailsCard(viewModel: _viewModel),
                            if (_viewModel.isLoggedIn) ...[
                              const SizedBox(height: AppSpacing.lg),
                              PersonalInfoLogoutButton(
                                isLoading: _viewModel.isLoggingOut,
                                onPressed: _handleLogout,
                              ),
                            ],
                            if (!_viewModel.isLoggedIn && !widget.embedded) ...[
                              const SizedBox(height: AppSpacing.lg),
                              PersonalInfoActions(
                                isLoggedIn: false,
                                onLogin: () => AppRoutes.openLogin(context),
                                onRegister: () => AppRoutes.openRegister(context),
                                onJockeyPortal: () {},
                                onRefereePortal: () {},
                                showGuestActions: true,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) {
      return _buildBody();
    }

    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.surface,
      appBar: const HomeAppBar(title: 'Thông tin cá nhân'),
      body: _buildBody(),
    );
  }
}
