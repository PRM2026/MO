import 'package:flutter/material.dart';

import '../../constants/app_constants.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../common/profile_avatar.dart';
import '../common/theme_mode_toggle.dart';

class OwnerAppBar extends StatelessWidget implements PreferredSizeWidget {
  const OwnerAppBar({
    super.key,
    this.profileImageUrl,
    this.showBack = false,
    this.titleOverride,
    this.onProfileTap,
    this.showSearchAction = false,
    this.onSearchTap,
    this.profileInteractive = true,
  });

  final String? profileImageUrl;
  final bool showBack;
  final String? titleOverride;
  final VoidCallback? onProfileTap;
  final bool showSearchAction;
  final VoidCallback? onSearchTap;
  final bool profileInteractive;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppBar(
      backgroundColor: scheme.surface.withValues(alpha: 0.92),
      foregroundColor: scheme.onSurface,
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
              ).copyWith(fontWeight: FontWeight.w700),
            )
          : Row(
              children: [
                const Icon(
                  Icons.home_work_outlined,
                  color: RefereeColors.championshipGold,
                  size: 28,
                ),
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
        const ThemeModeIconButton(),
        if (showSearchAction)
          IconButton(
            onPressed: onSearchTap,
            icon: Icon(Icons.search, color: scheme.onSurfaceVariant),
          ),
        ProfileAvatarButton(
          imageUrl: profileImageUrl,
          fallbackIcon: Icons.person_rounded,
          interactive: profileInteractive,
          onTap: profileInteractive ? onProfileTap : null,
          padding: const EdgeInsets.only(right: AppSpacing.md),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(height: 1, color: scheme.outlineVariant),
      ),
    );
  }
}
