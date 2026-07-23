import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_spacing.dart';
import '../constants/app_theme_tokens.dart';
import '../constants/auth_colors.dart';
import '../routes/app_routes.dart';
import '../utils/app_toast.dart';
import '../viewmodels/forgot_password_viewmodel.dart';
import '../widgets/auth/auth_background.dart';
import '../widgets/auth/auth_text_field.dart';
import '../widgets/auth/gold_cta_button.dart';

enum _ResetStep { email, otp, password }

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, this.viewModel});

  final ForgotPasswordViewModel? viewModel;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _otp = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();

  late final ForgotPasswordViewModel _viewModel;
  late final bool _ownsViewModel;
  _ResetStep _step = _ResetStep.email;
  Timer? _timer;
  int _resendSeconds = 0;

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _viewModel = widget.viewModel ?? ForgotPasswordViewModel();
    _viewModel.addListener(_onChanged);
    _otp.addListener(_onChanged);
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  void _startResendTimer() {
    _timer?.cancel();
    setState(() => _resendSeconds = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _resendSeconds <= 1) {
        timer.cancel();
        if (mounted) setState(() => _resendSeconds = 0);
        return;
      }
      setState(() => _resendSeconds--);
    });
  }

  Future<void> _sendOtp({bool resend = false}) async {
    if (!resend && !_formKey.currentState!.validate()) return;
    final success = await _viewModel.sendOtp(_email.text.trim());
    if (!mounted) return;
    if (!success) {
      AppToast.showError(context, _viewModel.errorMessage!);
      return;
    }
    _startResendTimer();
    if (!resend) setState(() => _step = _ResetStep.otp);
    AppToast.showSuccess(
      context,
      resend ? 'Đã gửi lại mã OTP.' : 'Mã OTP đã được gửi đến email.',
    );
  }

  void _confirmOtp() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _step = _ResetStep.password);
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await _viewModel.resetPassword(
      email: _email.text.trim(),
      otp: _otp.text.trim(),
      newPassword: _password.text,
    );
    if (!mounted) return;
    if (!success) {
      AppToast.showError(context, _viewModel.errorMessage!);
      return;
    }
    AppToast.showSuccess(context, 'Mật khẩu đã được cập nhật.');
    AppRoutes.openLogin(context, replace: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _viewModel.removeListener(_onChanged);
    _otp.removeListener(_onChanged);
    if (_ownsViewModel) _viewModel.dispose();
    _email.dispose();
    _otp.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuthColors.background,
      body: Stack(
        children: [
          const AuthBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.xl,
                AppSpacing.screenPadding,
                AppSpacing.xl,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _ResetHeader(step: _step),
                        const SizedBox(height: AppSpacing.section),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          child: switch (_step) {
                            _ResetStep.email => _emailStep(),
                            _ResetStep.otp => _otpStep(),
                            _ResetStep.password => _passwordStep(),
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        TextButton.icon(
                          onPressed: () =>
                              AppRoutes.openLogin(context, replace: true),
                          icon: const Icon(Icons.arrow_back, size: 18),
                          label: const Text('Quay lại đăng nhập'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emailStep() {
    return Column(
      key: const ValueKey('forgot-email-step'),
      children: [
        AuthTextField(
          label: 'Email',
          hint: 'example@racing.com',
          icon: Icons.mail_outline,
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          validator: _viewModel.validateEmail,
        ),
        const SizedBox(height: AppSpacing.lg),
        GoldCtaButton(
          label: 'Gửi mã OTP',
          isLoading: _viewModel.isSubmitting,
          onPressed: _sendOtp,
        ),
      ],
    );
  }

  Widget _otpStep() {
    return Column(
      key: const ValueKey('forgot-otp-step'),
      children: [
        Text(
          _email.text.trim(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.bodySm(AuthColors.slate500),
        ),
        const SizedBox(height: AppSpacing.md),
        AuthTextField(
          label: 'Mã OTP',
          hint: '000000',
          icon: Icons.password_outlined,
          controller: _otp,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          maxLength: 6,
          validator: _viewModel.validateOtp,
          suffix: SizedBox(
            width: 72,
            child: Center(
              child: Text(
                '${_otp.text.length}/6',
                style: AppTypography.bodySm(AuthColors.slate400),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        GoldCtaButton(label: 'Xác nhận OTP', onPressed: _confirmOtp),
        const SizedBox(height: AppSpacing.sm),
        TextButton(
          onPressed: _resendSeconds == 0 && !_viewModel.isSubmitting
              ? () => _sendOtp(resend: true)
              : null,
          child: Text(
            _resendSeconds == 0
                ? 'Gửi lại mã'
                : 'Gửi lại mã sau ${_resendSeconds}s',
          ),
        ),
      ],
    );
  }

  Widget _passwordStep() {
    return Column(
      key: const ValueKey('forgot-password-step'),
      children: [
        AuthTextField(
          label: 'Mật khẩu mới',
          hint: 'Tối thiểu 6 ký tự, gồm chữ và số',
          icon: Icons.lock_outline,
          controller: _password,
          obscureText: _viewModel.obscurePassword,
          validator: _viewModel.validatePassword,
          suffix: IconButton(
            onPressed: _viewModel.togglePasswordVisibility,
            icon: Icon(
              _viewModel.obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AuthTextField(
          label: 'Xác nhận mật khẩu',
          hint: 'Nhập lại mật khẩu mới',
          icon: Icons.lock_reset_outlined,
          controller: _confirmation,
          obscureText: _viewModel.obscureConfirmPassword,
          validator: (value) =>
              _viewModel.validateConfirmation(value, _password.text),
          suffix: IconButton(
            onPressed: _viewModel.toggleConfirmPasswordVisibility,
            icon: Icon(
              _viewModel.obscureConfirmPassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        GoldCtaButton(
          label: 'Cập nhật mật khẩu',
          isLoading: _viewModel.isSubmitting,
          onPressed: _resetPassword,
        ),
      ],
    );
  }
}

class _ResetHeader extends StatelessWidget {
  const _ResetHeader({required this.step});

  final _ResetStep step;

  @override
  Widget build(BuildContext context) {
    final (title, subtitle, icon) = switch (step) {
      _ResetStep.email => (
        'Quên mật khẩu',
        'Nhập email để nhận mã xác thực.',
        Icons.mark_email_read_outlined,
      ),
      _ResetStep.otp => (
        'Xác thực OTP',
        'Nhập mã 6 chữ số vừa được gửi tới bạn.',
        Icons.pin_outlined,
      ),
      _ResetStep.password => (
        'Mật khẩu mới',
        'Tạo mật khẩu an toàn cho tài khoản.',
        Icons.lock_reset_outlined,
      ),
    };
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AuthColors.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: Colors.white, size: 34),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(title, style: AppTypography.displayMd(AuthColors.navy)),
        const SizedBox(height: AppSpacing.sm),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: AppTypography.bodyMd(AuthColors.slate500),
        ),
      ],
    );
  }
}
