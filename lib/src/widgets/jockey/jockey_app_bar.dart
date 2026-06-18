import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../../constants/app_constants.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../common/brand_logo.dart';
import '../common/profile_avatar.dart';

class JockeyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const JockeyAppBar({
    super.key,
    this.profileImageUrl,
    this.showBack = false,
    this.titleOverride,
    this.showBrandTitle = true,
    this.showNotificationAction = true,
    this.onProfileTap,
    this.profileInteractive = true,
  });

  final String? profileImageUrl;
  final bool showBack;
  final String? titleOverride;
  final bool showBrandTitle;
  final bool showNotificationAction;
  final VoidCallback? onProfileTap;
  final bool profileInteractive;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: RefereeColors.background,
      foregroundColor: RefereeColors.onSurface,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: showBack
          ? IconButton(
              onPressed: () => Navigator.maybePop(context),
              icon: const Icon(
                Icons.arrow_back,
                color: RefereeColors.championshipGold,
              ),
            )
          : null,
      titleSpacing: AppSpacing.md,
      title: titleOverride != null
          ? Text(
              titleOverride!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.headlineSm(
                RefereeColors.championshipGold,
              ).copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.2),
            )
          : showBrandTitle
          ? Row(
              children: [
                const BrandLogo(size: 32),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    AppConstants.appName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.headlineSm(
                      RefereeColors.championshipGold,
                    ).copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            )
          : null,
      actions: [
        ProfileAvatarButton(
          imageUrl: profileImageUrl,
          fallbackIcon: Icons.sports_martial_arts_outlined,
          interactive: profileInteractive,
          onTap: profileInteractive
              ? (onProfileTap ?? () => AppRoutes.openJockeyProfile(context))
              : null,
          padding: const EdgeInsets.only(right: AppSpacing.md),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(height: 1, color: Colors.white.withValues(alpha: 0.1)),
      ),
    );
  }
}
