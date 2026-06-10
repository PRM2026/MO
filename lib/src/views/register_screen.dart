import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';
import '../constants/auth_colors.dart';
import '../routes/app_routes.dart';
import '../viewmodels/register_viewmodel.dart';
import '../widgets/auth/auth_background.dart';
import '../widgets/auth/auth_section_divider.dart';
import '../widgets/auth/auth_text_field.dart';
import '../widgets/auth/gold_cta_button.dart';
import '../widgets/auth/login_footer.dart';
import '../widgets/auth/register_brand_header.dart';
import '../widgets/auth/social_auth_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, this.viewModel});

  final RegisterViewModel? viewModel;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late final RegisterViewModel _viewModel;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? RegisterViewModel();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final success = await _viewModel.submit(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      AppRoutes.openLogin(context);
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
                              const RegisterBrandHeader(),
                              const SizedBox(height: AppSpacing.section),
                              AuthTextField(
                                label: 'Họ và tên',
                                hint: 'Nguyễn Văn A',
                                icon: Icons.person_outline,
                                controller: _nameController,
                                validator: _viewModel.validateFullName,
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              AuthTextField(
                                label: 'Email',
                                hint: 'email@example.com',
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
                              AuthTextField(
                                label: 'Xác nhận mật khẩu',
                                hint: '••••••••',
                                icon: Icons.lock_outline,
                                controller: _confirmPasswordController,
                                obscureText: _viewModel.obscureConfirmPassword,
                                validator: (value) =>
                                    _viewModel.validateConfirmPassword(
                                  value,
                                  _passwordController.text,
                                ),
                                suffix: IconButton(
                                  onPressed: () => setState(
                                    _viewModel.toggleConfirmPasswordVisibility,
                                  ),
                                  icon: Icon(
                                    _viewModel.obscureConfirmPassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: AuthColors.slate400,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              const RegisterInfoBox(),
                              const SizedBox(height: AppSpacing.lg),
                              GoldCtaButton(
                                label: 'Đăng ký',
                                isLoading: _isSubmitting,
                                onPressed: _handleSubmit,
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              const AuthSectionDivider(
                                label: 'Hoặc đăng ký với',
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
                  promptText: 'Đã có tài khoản? ',
                  actionLabel: 'Đăng nhập',
                  onActionTap: () => AppRoutes.openLogin(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
