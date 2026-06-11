import 'package:flutter/material.dart';

import '../../constants/referee_colors.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';
import '../../viewmodels/personal_info_viewmodel.dart';

class PersonalInfoHeaderCard extends StatelessWidget {
  const PersonalInfoHeaderCard({super.key, required this.viewModel});

  final PersonalInfoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final initial = viewModel.displayName.characters.first.toUpperCase();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              initial,
              style: AppTypography.displayLg(Colors.white).copyWith(fontSize: 32),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  viewModel.displayName,
                  style: AppTypography.headlineSm(AppColors.onSurface)
                      .copyWith(fontSize: 24),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    viewModel.roleLabel,
                    style: AppTypography.labelCaps(AppColors.primary)
                        .copyWith(fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PersonalInfoDetailsCard extends StatelessWidget {
  const PersonalInfoDetailsCard({super.key, required this.viewModel});

  final PersonalInfoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin tài khoản',
            style: AppTypography.headlineSm(AppColors.onSurface).copyWith(fontSize: 20),
          ),
          const SizedBox(height: 20),
          _InfoRow(
            label: 'Họ và tên',
            value: viewModel.displayName,
          ),
          const SizedBox(height: 16),
          _InfoRow(
            label: 'Email',
            value: viewModel.profile?.email?.isNotEmpty == true
                ? viewModel.profile!.email!
                : '—',
          ),
          const SizedBox(height: 16),
          _InfoRow(
            label: 'Vai trò đã được duyệt',
            value: viewModel.roleLabel,
          ),
          const SizedBox(height: 16),
          _InfoRow(
            label: 'Trạng thái đăng nhập',
            value: viewModel.isLoggedIn ? 'Đã đăng nhập' : 'Chưa đăng nhập',
          ),
        ],
      ),
    );
  }
}

class PersonalInfoLogoutButton extends StatelessWidget {
  const PersonalInfoLogoutButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: RefereeColors.statusRed.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: RefereeColors.statusRed.withValues(alpha: 0.22),
            ),
            boxShadow: [
              BoxShadow(
                color: RefereeColors.statusRed.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: RefereeColors.statusRed.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: RefereeColors.statusRed,
                        ),
                      )
                    : const Icon(
                        Icons.logout_rounded,
                        color: RefereeColors.statusRed,
                        size: 24,
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Đăng xuất',
                      style: AppTypography.headlineSm(RefereeColors.statusRed)
                          .copyWith(fontSize: 17),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Thoát khỏi tài khoản trên thiết bị này',
                      style: AppTypography.bodySm(AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: RefereeColors.statusRed.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelCaps(AppColors.onSurfaceVariant)
              .copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.bodyMd(AppColors.onSurface)
              .copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class PersonalInfoActions extends StatelessWidget {
  const PersonalInfoActions({
    super.key,
    required this.isLoggedIn,
    required this.onLogin,
    required this.onRegister,
    required this.onJockeyPortal,
    required this.onRefereePortal,
    this.showGuestActions = true,
    this.showJockeyPortal = false,
    this.showRefereePortal = false,
  });

  final bool isLoggedIn;
  final VoidCallback onLogin;
  final VoidCallback onRegister;
  final VoidCallback onJockeyPortal;
  final VoidCallback onRefereePortal;
  final bool showGuestActions;
  final bool showJockeyPortal;
  final bool showRefereePortal;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!isLoggedIn && showGuestActions) ...[
          FilledButton(
            onPressed: onLogin,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Đăng nhập'),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton(
            onPressed: onRegister,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.onSurface,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Đăng ký tài khoản'),
          ),
        ] else if (isLoggedIn) ...[
          if (showJockeyPortal) ...[
            FilledButton(
              onPressed: onJockeyPortal,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF15130F),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Vào portal jockey'),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          if (showRefereePortal) ...[
            FilledButton(
              onPressed: onRefereePortal,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0C1D36),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Vào portal trọng tài'),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ],
    );
  }
}
