import 'dart:ui';

import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';

import '../common/brand_logo.dart';
import 'home_bottom_nav.dart';
import '../../views/main_shell.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key, this.title});

  /// Mặc định hiển thị tên app; tab con truyền title riêng (vd: Giải đấu).
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
          actions: [
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.notifications_none,
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.9),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.lg),
              child: GestureDetector(
                onTap: () {
                  final shell = MainShell.of(context);
                  if (shell?.isLoggedIn == true) {
                    MainShell.selectTab(context, HomeTab.account);
                  } else {
                    AppRoutes.openLogin(context);
                  }
                },
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primaryContainer,
                  child: Text(
                    AppConstants.userInitials,
                    style: AppTypography.labelCaps(AppColors.onPrimaryContainer)
                        .copyWith(fontSize: 11),
                  ),
                ),
              ),
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
