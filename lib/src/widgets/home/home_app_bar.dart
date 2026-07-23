import 'dart:ui';

import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';

import '../common/brand_logo.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key, this.title, this.onLogin});

  /// Mặc định hiển thị [AppConstants.appName]; tab con có thể truyền title riêng.
  final String? title;
  final VoidCallback? onLogin;

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: preferredSize.height,
          titleSpacing: AppSpacing.screenPadding,
          title: Row(
            children: [
              const BrandLogo(size: 32),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title ?? AppConstants.appName.replaceFirst(' ', '\n'),
                  maxLines: title == null ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.headlineSm(AppColors.onSurface).copyWith(
                    fontSize: title == null ? 16 : 18,
                    height: title == null ? 1.05 : 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            if (onLogin != null)
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.md),
                child: _LoginAction(onPressed: onLogin!),
              ),
          ],
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

class _LoginAction extends StatelessWidget {
  const _LoginAction({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 132,
        height: 44,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.32),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              key: const ValueKey('home-login-action'),
              onTap: onPressed,
              borderRadius: BorderRadius.circular(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.login_rounded,
                    size: 18,
                    color: AppColors.onPrimary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Đăng nhập',
                    maxLines: 1,
                    softWrap: false,
                    style: AppTypography.labelCaps(
                      AppColors.onPrimary,
                    ).copyWith(letterSpacing: 0),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
