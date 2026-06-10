import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';
import '../../constants/auth_colors.dart';

class LoginBrandHeader extends StatelessWidget {
  const LoginBrandHeader({super.key});

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
            child: Icon(Icons.stars, color: Colors.white, size: 36),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Đăng nhập',
          style: AppTypography.displayMd(AuthColors.navy),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Chào mừng trở lại hệ thống quản lý giải đua ngựa',
          textAlign: TextAlign.center,
          style: AppTypography.bodyMd(AuthColors.slate500),
        ),
      ],
    );
  }
}
