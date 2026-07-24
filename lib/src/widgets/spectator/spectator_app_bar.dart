import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../common/profile_avatar.dart';
import '../common/theme_mode_toggle.dart';

class SpectatorAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SpectatorAppBar({
    super.key,
    this.profileImageUrl,
    this.onProfileTap,
    this.displayName = 'Khán giả',
    this.showProfileAvatar = true,
    this.titleOverride,
    this.profileInteractive = true,
  });

  final String? profileImageUrl;
  final VoidCallback? onProfileTap;
  final String displayName;
  final bool showProfileAvatar;
  final String? titleOverride;
  final bool profileInteractive;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final compact = titleOverride != null;
    final avatarSize = compact ? 32.0 : 40.0;

    return AppBar(
      backgroundColor: scheme.surface.withValues(alpha: 0.92),
      foregroundColor: scheme.onSurface,
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
        const ThemeModeIconButton(),
        if (showProfileAvatar)
          ProfileAvatarButton(
            imageUrl: profileImageUrl,
            size: avatarSize,
            fallbackIcon: Icons.person_rounded,
            interactive: profileInteractive,
            onTap: profileInteractive ? onProfileTap : null,
            padding: EdgeInsets.only(right: AppSpacing.screenPadding),
          ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(height: 1, color: scheme.outlineVariant),
      ),
    );
  }
}
