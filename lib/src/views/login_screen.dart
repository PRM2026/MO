import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';
import '../constants/app_theme_tokens.dart';
import '../constants/auth_colors.dart';
import '../routes/app_routes.dart';
import '../viewmodels/login_viewmodel.dart';
import '../widgets/auth/auth_background.dart';
import '../widgets/auth/auth_section_divider.dart';
import '../widgets/auth/auth_text_field.dart';
import '../widgets/auth/gold_cta_button.dart';
import '../widgets/auth/login_brand_header.dart';
import '../widgets/auth/login_footer.dart';
import '../widgets/auth/social_auth_button.dart';

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
      AppRoutes.openHome(context);
    }
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
                              const LoginBrandHeader(),
                              const SizedBox(height: AppSpacing.section),
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
                                  () => _viewModel.rememberMe = value ?? false,
                                ),
                                onForgotPassword: () {},
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              GoldCtaButton(
                                label: 'Đăng nhập',
                                isLoading: _isSubmitting,
                                onPressed: _handleSubmit,
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              const AuthSectionDivider(
                                label: 'Hoặc đăng nhập với',
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              const Row(
                                children: [
                                  Expanded(
                                    child: SocialAuthButton(
                                      provider: SocialProvider.google,
                                    ),
                                  ),
                                  SizedBox(width: AppSpacing.lg),
                                  Expanded(
                                    child: SocialAuthButton(
                                      provider: SocialProvider.facebook,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                LoginFooter(
                  onActionTap: () => AppRoutes.openRegister(context),
                ),
              ],
            ),
          ),
        ],
      ),
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
