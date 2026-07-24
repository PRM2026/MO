import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../../repositories/jockey_notification_repository.dart';
import '../../constants/app_constants.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../common/brand_logo.dart';
import '../common/profile_avatar.dart';
import '../common/theme_mode_toggle.dart';

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
    this.notificationUnreadCount,
    this.onNotificationTap,
    this.notificationRepository,
  });

  final String? profileImageUrl;
  final bool showBack;
  final String? titleOverride;
  final bool showBrandTitle;
  final bool showNotificationAction;
  final VoidCallback? onProfileTap;
  final bool profileInteractive;
  final int? notificationUnreadCount;
  final Future<void> Function()? onNotificationTap;
  final JockeyNotificationRepository? notificationRepository;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppBar(
      backgroundColor: scheme.surface,
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
        const ThemeModeIconButton(),
        if (showNotificationAction)
          JockeyNotificationAction(
            unreadCount: notificationUnreadCount,
            onTap: onNotificationTap,
            repository: notificationRepository,
          ),
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
        child: Divider(height: 1, color: scheme.outlineVariant),
      ),
    );
  }
}

class JockeyNotificationAction extends StatefulWidget {
  const JockeyNotificationAction({
    super.key,
    this.unreadCount,
    this.onTap,
    this.repository,
  });

  final int? unreadCount;
  final Future<void> Function()? onTap;
  final JockeyNotificationRepository? repository;

  @override
  State<JockeyNotificationAction> createState() =>
      _JockeyNotificationActionState();
}

class _JockeyNotificationActionState extends State<JockeyNotificationAction> {
  late final JockeyNotificationRepository _repository;
  int _unreadCount = 0;

  int get _visibleCount => widget.unreadCount ?? _unreadCount;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? JockeyNotificationRepository();
    if (widget.unreadCount == null) {
      _loadCount();
    }
  }

  @override
  void didUpdateWidget(covariant JockeyNotificationAction oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.unreadCount != widget.unreadCount &&
        widget.unreadCount == null) {
      _loadCount();
    }
  }

  Future<void> _loadCount() async {
    try {
      final response = await _repository.fetchUnreadCount();
      if (!mounted) return;
      setState(() => _unreadCount = response.count);
    } catch (_) {
      // The bell remains usable even when its badge cannot be refreshed.
    }
  }

  Future<void> _handleTap() async {
    final callback = widget.onTap;
    if (callback != null) {
      await callback();
    } else {
      await AppRoutes.openJockeyNotifications(context);
    }
    if (mounted && widget.unreadCount == null) {
      await _loadCount();
    }
  }

  @override
  Widget build(BuildContext context) {
    final count = _visibleCount;
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            key: const Key('jockey-notification-bell'),
            tooltip: 'Thông báo',
            onPressed: _handleTap,
            icon: const Icon(
              Icons.notifications_none_outlined,
              color: RefereeColors.onSurface,
            ),
          ),
          if (count > 0)
            Positioned(
              key: const Key('jockey-notification-badge'),
              right: 2,
              top: 5,
              child: Container(
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: RefereeColors.statusRed,
                  borderRadius: BorderRadius.all(Radius.circular(999)),
                ),
                child: Text(
                  count > 99 ? '99+' : '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
