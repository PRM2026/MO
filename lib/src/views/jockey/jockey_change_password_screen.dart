import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../utils/app_toast.dart';
import '../../viewmodels/referee_change_password_viewmodel.dart';
import '../../widgets/jockey/jockey_app_bar.dart';
import '../../widgets/jockey/jockey_dashboard_widgets.dart';
import '../../widgets/referee/referee_change_password_widgets.dart';
import '../../widgets/referee/referee_glass_card.dart';

class JockeyChangePasswordScreen extends StatefulWidget {
  const JockeyChangePasswordScreen({
    super.key,
    this.viewModel,
    this.profileImageUrl,
    this.portalName = 'Jockey Portal',
  });

  final RefereeChangePasswordViewModel? viewModel;
  final String? profileImageUrl;
  final String portalName;

  @override
  State<JockeyChangePasswordScreen> createState() =>
      _JockeyChangePasswordScreenState();
}

class _JockeyChangePasswordScreenState
    extends State<JockeyChangePasswordScreen> {
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

    AppToast.showSuccess(context, 'Mật khẩu đã được thay đổi thành công!');
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
      appBar: JockeyAppBar(
        showBack: true,
        titleOverride: 'ĐỔI MẬT KHẨU',
        showBrandTitle: false,
        profileImageUrl: widget.profileImageUrl,
        profileInteractive: false,
      ),
      body: JockeySpeedlineBackground(
        child: Stack(
          children: [
            Positioned(
              top: -120,
              right: -120,
              child: Container(
                width: 500,
                height: 500,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: RefereeColors.championshipGold.withValues(alpha: 0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -120,
              left: -120,
              child: Container(
                width: 500,
                height: 500,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: RefereeColors.portalSurface.withValues(alpha: 0.3),
                ),
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.xl,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 512),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      RefereeGlassCard(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Để đảm bảo an toàn cho tài khoản ${widget.portalName}, vui lòng không chia sẻ mật khẩu mới với bất kỳ ai.',
                              textAlign: TextAlign.center,
                              style: AppTypography.bodyMd(
                                RefereeColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 24),
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
                              onPressed: _viewModel.isSubmitting
                                  ? null
                                  : _handleSubmit,
                              style: FilledButton.styleFrom(
                                backgroundColor: RefereeColors.championshipGold,
                                foregroundColor: RefereeColors.portalSurface,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
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
                                      style:
                                          AppTypography.labelCaps(
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
                      const SizedBox(height: 32),
                      TextButton(
                        onPressed: () {
                          AppToast.showSuccess(
                            context,
                            'Vui lòng liên hệ ban quản lý để được hỗ trợ.',
                          );
                        },
                        child: Text(
                          'Bạn quên mật khẩu hiện tại? Liên hệ ban quản lý',
                          style:
                              AppTypography.labelCaps(
                                RefereeColors.championshipGold.withValues(
                                  alpha: 0.6,
                                ),
                              ).copyWith(
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline,
                                decorationColor: RefereeColors.championshipGold
                                    .withValues(alpha: 0.6),
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
