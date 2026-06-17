import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../utils/app_toast.dart';
import '../../viewmodels/referee_change_password_viewmodel.dart';
import '../../widgets/referee/referee_app_bar.dart';
import '../../widgets/referee/referee_change_password_widgets.dart';
import '../../widgets/referee/referee_glass_card.dart';

class RefereeChangePasswordScreen extends StatefulWidget {
  const RefereeChangePasswordScreen({
    super.key,
    this.viewModel,
    this.profileImageUrl,
  });

  final RefereeChangePasswordViewModel? viewModel;
  final String? profileImageUrl;

  @override
  State<RefereeChangePasswordScreen> createState() =>
      _RefereeChangePasswordScreenState();
}

class _RefereeChangePasswordScreenState
    extends State<RefereeChangePasswordScreen> {
  late final RefereeChangePasswordViewModel _viewModel;
  late final bool _ownsViewModel;
  late final TextEditingController _currentController;
  late final TextEditingController _newController;
  late final TextEditingController _confirmController;

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _viewModel = widget.viewModel ?? RefereeChangePasswordViewModel();
    _viewModel.addListener(_onChanged);
    _currentController = TextEditingController();
    _newController = TextEditingController();
    _confirmController = TextEditingController();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _handleSubmit() async {
    final success = await _viewModel.submit(
      currentPassword: _currentController.text,
      newPassword: _newController.text,
      confirmPassword: _confirmController.text,
    );
    if (!mounted) return;

    if (!success) {
      final message = _viewModel.errorMessage;
      if (message != null && message.isNotEmpty) {
        AppToast.showError(context, message);
      }
      return;
    }

    AppToast.showSuccess(
      context,
      'Cập nhật thành công!',
      subtitle: 'Mật khẩu của bạn đã được thay đổi.',
    );
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onChanged);
    if (_ownsViewModel) _viewModel.dispose();
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RefereeColors.background,
      appBar: RefereeAppBar(
        showBack: true,
        titleOverride: 'ĐỔI MẬT KHẨU',
        profileImageUrl: widget.profileImageUrl,
        profileInteractive: false,
      ),
      body: RefereeChangePasswordGlowBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.xl,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Bảo mật tài khoản',
                    style: AppTypography.displayLg(RefereeColors.onSurface)
                        .copyWith(fontSize: 28),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vui lòng nhập mật khẩu hiện tại và mật khẩu mới để cập nhật thông tin bảo mật.',
                    style: AppTypography.bodyMd(RefereeColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  RefereeGlassCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        RefereePasswordField(
                          label: 'Mật khẩu hiện tại',
                          controller: _currentController,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 20),
                        RefereePasswordField(
                          label: 'Mật khẩu mới',
                          controller: _newController,
                          onChanged: _viewModel.updateNewPasswordStrength,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),
                        PasswordStrengthIndicator(
                          strength: _viewModel.newPasswordStrength,
                        ),
                        const SizedBox(height: 20),
                        RefereePasswordField(
                          label: 'Xác nhận mật khẩu mới',
                          controller: _confirmController,
                          textInputAction: TextInputAction.done,
                        ),
                        const SizedBox(height: 24),
                        const PasswordSecurityRequirements(),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed:
                              _viewModel.isSubmitting ? null : _handleSubmit,
                          style: FilledButton.styleFrom(
                            backgroundColor: RefereeColors.tertiary,
                            foregroundColor: RefereeColors.portalSurface,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                            shadowColor:
                                RefereeColors.championshipGold.withValues(
                              alpha: 0.2,
                            ),
                          ),
                          child: _viewModel.isSubmitting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: RefereeColors.portalSurface,
                                  ),
                                )
                              : Text(
                                  'CẬP NHẬT MẬT KHẨU',
                                  style: AppTypography.labelCaps(
                                    RefereeColors.portalSurface,
                                  ).copyWith(
                                    fontSize: 14,
                                    letterSpacing: 1.2,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
