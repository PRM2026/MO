import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_theme_tokens.dart';
import '../models/role_request_data.dart';
import '../utils/app_toast.dart';
import '../viewmodels/role_request_viewmodel.dart';
import '../widgets/role_request/role_request_widgets.dart';

class RoleRequestScreen extends StatefulWidget {
  const RoleRequestScreen({super.key, this.viewModel, this.embedded = false});

  final RoleRequestViewModel? viewModel;
  final bool embedded;

  @override
  State<RoleRequestScreen> createState() => _RoleRequestScreenState();
}

class _RoleRequestScreenState extends State<RoleRequestScreen> {
  late final RoleRequestViewModel _viewModel;
  late final bool _ownsViewModel;

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _viewModel = widget.viewModel ?? RoleRequestViewModel();
    _viewModel.addListener(_onChanged);
    _viewModel.loadData();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _openRoleForm(SystemRoleType role) async {
    final fullName = _viewModel.overview?.displayName ?? '';
    final success = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RoleRequestModalSheet(
        role: role,
        fullName: fullName,
        isSubmitting: _viewModel.isSubmitting,
        onSubmit: (values, files) =>
            _viewModel.submitApplication(role, values, files),
      ),
    );

    if (!mounted || success != true) return;
    AppToast.showSuccess(
      context,
      'Đã gửi yêu cầu xét duyệt',
      subtitle: 'Ban quản trị sẽ phản hồi trong thời gian sớm nhất.',
    );
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onChanged);
    if (_ownsViewModel) _viewModel.dispose();
    super.dispose();
  }

  Widget _buildBody() {
    final overview = _viewModel.overview;

    if (_viewModel.isLoading && overview == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    return RefreshIndicator(
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
                  constraints: const BoxConstraints(maxWidth: 1280),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Đăng ký vai trò hệ thống',
                        style: AppTypography.displayLg(
                          AppColors.onSurface,
                        ).copyWith(fontSize: 28),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Nâng cấp tài khoản của bạn để truy cập các tính năng chuyên biệt cho chuyên gia.',
                        style: AppTypography.bodyMd(AppColors.onSurfaceVariant),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        'Chọn vai trò bạn muốn ứng tuyển',
                        style: AppTypography.headlineSm(
                          AppColors.onSurface,
                        ).copyWith(fontSize: 22),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      RoleSelectorGrid(onRoleTap: _openRoleForm),
                      const SizedBox(height: AppSpacing.xl),
                      RoleRequestHistorySection(history: overview!.history),
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
    return ColoredBox(color: AppColors.surface, child: _buildBody());
  }
}
