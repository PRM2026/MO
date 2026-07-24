import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_spacing.dart';
import '../constants/app_theme_tokens.dart';
import '../constants/auth_colors.dart';
import '../routes/app_routes.dart';
import '../utils/app_toast.dart';
import '../viewmodels/login_viewmodel.dart';
import '../widgets/auth/auth_back_button.dart';
import '../widgets/auth/auth_background.dart';
import '../widgets/auth/auth_text_field.dart';
import '../widgets/auth/gold_cta_button.dart';
import '../widgets/auth/login_brand_header.dart';
import '../widgets/auth/login_footer.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.viewModel});

  final LoginViewModel? viewModel;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();

  late final LoginViewModel _viewModel;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? LoginViewModel();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final success = await _viewModel.submit(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      if (!mounted) return;
      AppToast.showSuccess(context, 'Đăng nhập thành công!');
      await AppRoutes.openAfterAuth(context);
      return;
    }

    if (_viewModel.errorMessage != null) {
      AppToast.showError(context, _viewModel.errorMessage!);
    }
  }

  Future<void> _handleTwoFactorSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    final success = await _viewModel.verifyTwoFactor(_otpController.text);
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    if (!success) {
      AppToast.showError(context, _viewModel.errorMessage!);
      return;
    }
    AppToast.showSuccess(context, 'Xác thực đăng nhập thành công!');
    await AppRoutes.openAfterAuth(context);
  }

  Future<void> _resendTwoFactor() async {
    setState(() => _isSubmitting = true);
    final success = await _viewModel.resendTwoFactor();
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    if (success) {
      AppToast.showSuccess(context, 'Đã gửi lại mã xác thực.');
    } else {
      AppToast.showError(context, _viewModel.errorMessage!);
    }
  }

  void _handleBack() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }
    AppRoutes.openAfterLogout(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuthColors.background,
      body: Stack(
        children: [
          const AuthBackground(),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenPadding,
                      AppSpacing.xl,
                      AppSpacing.screenPadding,
                      AppSpacing.lg,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              if (_viewModel.requiresTwoFactor)
                                _TwoFactorHeader(
                                  email: _viewModel.maskedEmail ?? '',
                                )
                              else
                                const LoginBrandHeader(),
                              const SizedBox(height: AppSpacing.section),
                              if (_viewModel.requiresTwoFactor) ...[
                                AuthTextField(
                                  label: 'Mã xác thực',
                                  hint: '000000',
                                  icon: Icons.pin_outlined,
                                  controller: _otpController,
                                  keyboardType: TextInputType.number,
                                  validator: _viewModel.validateOtp,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  maxLength: 6,
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                GoldCtaButton(
                                  label: 'Xác thực đăng nhập',
                                  isLoading: _isSubmitting,
                                  onPressed: _handleTwoFactorSubmit,
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextButton(
                                      onPressed: _isSubmitting
                                          ? null
                                          : () => setState(() {
                                              _viewModel.cancelTwoFactor();
                                              _otpController.clear();
                                            }),
                                      child: const Text('Đăng nhập lại'),
                                    ),
                                    TextButton(
                                      onPressed: _isSubmitting
                                          ? null
                                          : _resendTwoFactor,
                                      child: const Text('Gửi lại mã'),
                                    ),
                                  ],
                                ),
                              ] else ...[
                                AuthTextField(
                                  label: 'Email',
                                  hint: 'example@racing.com',
                                  icon: Icons.mail_outline,
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: _viewModel.validateEmail,
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                AuthTextField(
                                  label: 'Mật khẩu',
                                  hint: '••••••••',
                                  icon: Icons.lock_outline,
                                  controller: _passwordController,
                                  obscureText: _viewModel.obscurePassword,
                                  validator: _viewModel.validatePassword,
                                  suffix: IconButton(
                                    onPressed: () => setState(
                                      _viewModel.togglePasswordVisibility,
                                    ),
                                    icon: Icon(
                                      _viewModel.obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: AuthColors.slate400,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                _LoginOptionsRow(
                                  rememberMe: _viewModel.rememberMe,
                                  onRememberChanged: (value) => setState(
                                    () =>
                                        _viewModel.rememberMe = value ?? false,
                                  ),
                                  onForgotPassword: () =>
                                      AppRoutes.openForgotPassword(context),
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                GoldCtaButton(
                                  label: 'Đăng nhập',
                                  isLoading: _isSubmitting,
                                  onPressed: _handleSubmit,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                LoginFooter(
                  onActionTap: () =>
                      AppRoutes.openRegister(context, replace: true),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Align(
                alignment: Alignment.topLeft,
                child: AuthBackButton(onPressed: _handleBack),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TwoFactorHeader extends StatelessWidget {
  const _TwoFactorHeader({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AuthColors.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.verified_user_outlined,
            color: Colors.white,
            size: 36,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Xác thực 2 bước',
          style: AppTypography.displayMd(AuthColors.navy),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Mã 6 chữ số đã được gửi tới $email',
          textAlign: TextAlign.center,
          style: AppTypography.bodyMd(AuthColors.slate500),
        ),
      ],
    );
  }
}

class _LoginOptionsRow extends StatelessWidget {
  const _LoginOptionsRow({
    required this.rememberMe,
    required this.onRememberChanged,
    required this.onForgotPassword,
  });

  final bool rememberMe;
  final ValueChanged<bool?> onRememberChanged;
  final VoidCallback onForgotPassword;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CheckboxListTile(
            value: rememberMe,
            onChanged: onRememberChanged,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: AuthColors.primary,
            title: Text(
              'Ghi nhớ đăng nhập',
              style: AppTypography.bodySm(AuthColors.slate600),
            ),
            dense: true,
            visualDensity: VisualDensity.compact,
          ),
        ),
        TextButton(
          onPressed: onForgotPassword,
          child: Text(
            'QUÊN MẬT KHẨU?',
            style: AppTypography.labelCaps(AuthColors.primaryDark),
          ),
        ),
      ],
    );
  }
}
