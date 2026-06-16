import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../news/news_network_image.dart';

class SpectatorAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SpectatorAppBar({
    super.key,
    this.profileImageUrl,
    this.onProfileTap,
    this.displayName = 'Khán giả',
    this.showProfileAvatar = true,
    this.titleOverride,
  });

  final String? profileImageUrl;
  final VoidCallback? onProfileTap;
  final String displayName;
  final bool showProfileAvatar;
  final String? titleOverride;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final avatarUrl = profileImageUrl;

    return AppBar(
      backgroundColor: (titleOverride != null
              ? RefereeColors.background
              : RefereeColors.portalSurface)
          .withValues(alpha: 0.8),
      foregroundColor: RefereeColors.onSurface,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: AppSpacing.screenPadding,
      title: Row(
        children: [
          const Icon(
            Icons.token,
            color: RefereeColors.championshipGold,
            size: 24,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              titleOverride ?? 'Xin chào, $displayName',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.headlineSm(RefereeColors.championshipGold)
                  .copyWith(
                fontSize: titleOverride != null ? 24 : 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      actions: [
        if (showProfileAvatar)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.screenPadding),
            child: GestureDetector(
              onTap: onProfileTap,
              child: Container(
                width: titleOverride != null ? 32 : 40,
                height: titleOverride != null ? 32 : 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: RefereeColors.championshipGold.withValues(
                      alpha: titleOverride != null ? 0.3 : 1,
                    ),
                    width: titleOverride != null ? 1 : 2,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: avatarUrl != null && avatarUrl.isNotEmpty
                    ? NewsNetworkImage(imageUrl: avatarUrl)
                    : ColoredBox(
                        color: RefereeColors.secondaryContainer,
                        child: Icon(
                          Icons.person,
                          color: RefereeColors.championshipGold.withValues(
                            alpha: 0.8,
                          ),
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
