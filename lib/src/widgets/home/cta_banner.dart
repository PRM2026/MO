import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';

class CtaBanner extends StatelessWidget {
  const CtaBanner({
    super.key,
    this.onRegister,
    this.onLogin,
  });

  final VoidCallback? onRegister;
  final VoidCallback? onLogin;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppColors.goldGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            Text(
              'Sẵn sàng tham gia cuộc đua?',
              textAlign: TextAlign.center,
              style: AppTypography.displayMd(AppColors.onPrimary),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Gia nhập cộng đồng đua ngựa hàng đầu để nhận ưu đãi và tin tức mới nhất.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMd(
                AppColors.onPrimary.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [
                FilledButton(
                  onPressed: onRegister,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.onSurface,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'ĐĂNG KÝ NGAY',
                    style: AppTypography.labelCaps(Colors.white),
                  ),
                ),
                OutlinedButton(
                  onPressed: onLogin,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.onPrimary,
                    side: BorderSide(
                      color: AppColors.onPrimary.withValues(alpha: 0.15),
                    ),
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'ĐĂNG NHẬP',
                    style: AppTypography.labelCaps(AppColors.onPrimary),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
