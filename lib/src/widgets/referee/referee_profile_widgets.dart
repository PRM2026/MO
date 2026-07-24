import 'package:flutter/material.dart';

import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../models/referee_profile_data.dart';
import '../common/profile_avatar.dart';
import 'referee_glass_card.dart';

class RefereeProfileHeader extends StatelessWidget {
  const RefereeProfileHeader({
    super.key,
    required this.profile,
    this.fallbackIcon = Icons.shield_outlined,
  });

  final RefereeProfileData profile;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    return RefereeGlassCard(
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 640;

          final avatar = ProfileAvatar(
            size: isWide ? 128 : 96,
            imageUrl: profile.avatarUrl,
            fallbackIcon: fallbackIcon,
            showOnlineIndicator: true,
            isOnline: profile.isOnline,
            ringWidth: 3,
          );

          final info = Column(
            crossAxisAlignment: isWide
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              Text(
                profile.fullName,
                textAlign: isWide ? TextAlign.start : TextAlign.center,
                style: AppTypography.displayLg(
                  RefereeColors.onSurface,
                ).copyWith(fontSize: isWide ? 32 : 28),
              ),
              const SizedBox(height: 8),
              Wrap(
                alignment: isWide ? WrapAlignment.start : WrapAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  _RankBadge(label: profile.rankLabel),
                  _RefereeIdBadge(id: profile.refereeId),
                ],
              ),
              const SizedBox(height: 16),
              Align(
                alignment: isWide ? Alignment.centerLeft : Alignment.center,
                child: Container(
                  width: 96,
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: LinearGradient(
                      colors: [
                        RefereeColors.tertiary,
                        RefereeColors.tertiary.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );

          if (isWide) {
            return Row(
              children: [
                avatar,
                const SizedBox(width: 24),
                Expanded(child: info),
              ],
            );
          }

          return Column(children: [avatar, const SizedBox(height: 20), info]);
        },
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: RefereeColors.secondaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: RefereeColors.secondary.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.labelCaps(
          RefereeColors.secondary,
        ).copyWith(fontSize: 11, letterSpacing: 0.8),
      ),
    );
  }
}

class _RefereeIdBadge extends StatelessWidget {
  const _RefereeIdBadge({required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'ID: $id',
        style: AppTypography.bodySm(
          RefereeColors.onSurfaceVariant,
        ).copyWith(fontWeight: FontWeight.w500),
      ),
    );
  }
}

class RefereeProfileStatsGrid extends StatelessWidget {
  const RefereeProfileStatsGrid({super.key, required this.stats});

  final List<RefereeProfileStat> stats;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 720;
        final crossAxisCount = isWide ? 2 : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: isWide ? 2.4 : 2.8,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) => _ProfileStatTile(stat: stats[index]),
        );
      },
    );
  }
}

class _ProfileStatTile extends StatelessWidget {
  const _ProfileStatTile({required this.stat});

  final RefereeProfileStat stat;

  @override
  Widget build(BuildContext context) {
    return RefereeGlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: stat.iconBackgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(stat.icon, color: stat.iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  stat.label,
                  style: AppTypography.labelCaps(
                    RefereeColors.onSurfaceVariant,
                  ).copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  stat.value,
                  style: AppTypography.headlineSm(
                    stat.iconColor == RefereeColors.tertiary
                        ? RefereeColors.tertiary
                        : RefereeColors.onSurface,
                  ).copyWith(fontSize: 22, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RefereeProfileSettingsCard extends StatelessWidget {
  const RefereeProfileSettingsCard({
    super.key,
    required this.settings,
    this.onItemTap,
  });

  final List<RefereeProfileSettingItem> settings;
  final ValueChanged<RefereeProfileSettingItem>? onItemTap;

  @override
  Widget build(BuildContext context) {
    return RefereeGlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              border: Border(
                bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
              ),
            ),
            child: Text(
              'CÀI ĐẶT TÀI KHOẢN',
              style: AppTypography.labelCaps(
                RefereeColors.onSurfaceVariant,
              ).copyWith(letterSpacing: 1.2),
            ),
          ),
          for (var i = 0; i < settings.length; i++) ...[
            _SettingsRow(
              item: settings[i],
              onTap: () => onItemTap?.call(settings[i]),
            ),
            if (i < settings.length - 1)
              Divider(height: 1, color: Colors.white.withValues(alpha: 0.05)),
          ],
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.item, this.onTap});

  final RefereeProfileSettingItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? item.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Icon(item.icon, color: item.iconColor, size: 22),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  item.title,
                  style: AppTypography.bodyMd(RefereeColors.onSurface),
                ),
              ),
              if (item.trailingLabel != null) ...[
                Text(
                  item.trailingLabel!,
                  style: AppTypography.labelCaps(
                    RefereeColors.onSurfaceVariant,
                  ).copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 8),
              ],
              Icon(Icons.chevron_right, color: RefereeColors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class RefereeProfileLogoutButton extends StatelessWidget {
  const RefereeProfileLogoutButton({
    super.key,
    required this.onPressed,
    required this.isLoading,
  });

  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: RefereeColors.statusRed,
        side: BorderSide(color: RefereeColors.statusRed.withValues(alpha: 0.3)),
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: isLoading
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: RefereeColors.statusRed,
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.logout),
                const SizedBox(width: 12),
                Text(
                  'Đăng xuất',
                  style: AppTypography.headlineSm(
                    RefereeColors.statusRed,
                  ).copyWith(fontSize: 18),
                ),
              ],
            ),
    );
  }
}
