import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../../constants/app_constants.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../common/brand_logo.dart';
import '../news/news_network_image.dart';

class RefereeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const RefereeAppBar({
    super.key,
    this.profileImageUrl,
    this.showBack = false,
    this.onProfileTap,
    this.titleOverride,
    this.showNotificationAction = true,
  });

  final String? profileImageUrl;
  final bool showBack;
  final VoidCallback? onProfileTap;
  final String? titleOverride;
  final bool showNotificationAction;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: RefereeColors.portalSurface,
      foregroundColor: RefereeColors.onSurface,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: showBack
          ? IconButton(
              onPressed: () => Navigator.maybePop(context),
              icon: const Icon(Icons.arrow_back),
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
          : Row(
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
            ),
      actions: [
        if (showNotificationAction)
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.notifications_none,
              color: RefereeColors.onSurfaceVariant.withValues(alpha: 0.9),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.lg),
          child: GestureDetector(
            onTap: onProfileTap ?? () => AppRoutes.openRefereeProfile(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: RefereeColors.tertiary, width: 2),
              ),
              clipBehavior: Clip.antiAlias,
              child: profileImageUrl != null && profileImageUrl!.isNotEmpty
                  ? NewsNetworkImage(imageUrl: profileImageUrl!)
                  : CircleAvatar(
                      backgroundColor: RefereeColors.secondaryContainer,
                      child: Icon(
                        Icons.gavel,
                        color: RefereeColors.onSecondaryContainer,
                        size: 20,
                      ),
                    ),
            ),
          ),
        ),
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
