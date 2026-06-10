import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../../constants/app_constants.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../common/brand_logo.dart';
import '../news/news_network_image.dart';

class JockeyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const JockeyAppBar({
    super.key,
    this.profileImageUrl,
    this.showBack = false,
    this.titleOverride,
    this.showBrandTitle = true,
    this.showNotificationAction = true,
    this.onProfileTap,
  });

  final String? profileImageUrl;
  final bool showBack;
  final String? titleOverride;
  final bool showBrandTitle;
  final bool showNotificationAction;
  final VoidCallback? onProfileTap;

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
              style: AppTypography.headlineSm(RefereeColors.championshipGold)
                  .copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
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
        if (profileImageUrl != null && profileImageUrl!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: onProfileTap ?? () => AppRoutes.openJockeyProfile(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: RefereeColors.championshipGold,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: NewsNetworkImage(imageUrl: profileImageUrl!),
              ),
            ),
          ),
        if (showNotificationAction)
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none,
              color: RefereeColors.championshipGold,
            ),
          ),
        const SizedBox(width: AppSpacing.sm),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(
          height: 1,
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
    );
  }
}
