import 'dart:ui';

import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';

import '../common/brand_logo.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key, this.title});

  /// Mặc định hiển thị [AppConstants.appName]; tab con có thể truyền title riêng.
  final String? title;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: AppBar(
          automaticallyImplyLeading: false,
          titleSpacing: AppSpacing.sm,
          title: Row(
            children: [
              const BrandLogo(size: 28),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title ?? AppConstants.appName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.headlineSm(AppColors.primary),
                ),
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Divider(
              height: 1,
              color: AppColors.outlineVariant.withValues(alpha: 0.4),
            ),
          ),
        ),
      ),
    );
  }
}
