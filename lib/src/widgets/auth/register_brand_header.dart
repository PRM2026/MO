import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';
import '../../constants/auth_colors.dart';

class RegisterBrandHeader extends StatelessWidget {
  const RegisterBrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: AuthColors.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AuthColors.primary.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const SizedBox(
            width: 64,
            height: 64,
            child: Icon(Icons.emoji_events, color: Colors.white, size: 36),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text('Đăng ký', style: AppTypography.displayMd(AuthColors.navy)),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Tham gia hệ thống quản lý giải đua ngựa',
          textAlign: TextAlign.center,
          style: AppTypography.bodyMd(AuthColors.slate500),
        ),
      ],
    );
  }
}

class RegisterInfoBox extends StatelessWidget {
  const RegisterInfoBox({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AuthColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AuthColors.primary.withValues(alpha: 0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.info_outline,
              color: AuthColors.primaryDark,
              size: 22,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                'Tài khoản sẽ được quản trị viên xác minh và cấp quyền phù hợp.',
                style: AppTypography.bodySm(AuthColors.slate600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
