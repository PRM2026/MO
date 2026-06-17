import 'package:flutter/material.dart';

import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../models/owner_profile_data.dart';
import '../common/profile_avatar.dart';
import '../referee/referee_glass_card.dart';

class OwnerProfileHeader extends StatelessWidget {
  const OwnerProfileHeader({super.key, required this.profile});

  final OwnerProfileData profile;

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
            fallbackIcon: Icons.home_work_outlined,
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
                  _OwnerBadge(label: profile.roleLabel),
                  if (profile.displayId != null)
                    _OwnerBadge(label: 'ID: ${profile.displayId!}'),
                ],
              ),
              if (profile.email != null || profile.username != null) ...[
                const SizedBox(height: 16),
                if (profile.email != null)
                  _OwnerProfileLine(
                    icon: Icons.mail_outline,
                    value: profile.email!,
                  ),
                if (profile.username != null)
                  _OwnerProfileLine(
                    icon: Icons.alternate_email,
                    value: profile.username!,
                  ),
              ],
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

class OwnerProfileSettingsCard extends StatelessWidget {
  const OwnerProfileSettingsCard({
    super.key,
    required this.settings,
    this.onItemTap,
  });

  final List<OwnerProfileSettingItem> settings;
  final ValueChanged<OwnerProfileSettingItem>? onItemTap;

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
            _OwnerSettingsRow(
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

class OwnerProfileLogoutButton extends StatelessWidget {
  const OwnerProfileLogoutButton({
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

class _OwnerBadge extends StatelessWidget {
  const _OwnerBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: RefereeColors.championshipGold.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: RefereeColors.championshipGold.withValues(alpha: 0.28),
        ),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.labelCaps(
          RefereeColors.championshipGold,
        ).copyWith(fontSize: 11),
      ),
    );
  }
}

class _OwnerProfileLine extends StatelessWidget {
  const _OwnerProfileLine({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: RefereeColors.onSurfaceVariant),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodyMd(RefereeColors.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

class _OwnerSettingsRow extends StatelessWidget {
  const _OwnerSettingsRow({required this.item, this.onTap});

  final OwnerProfileSettingItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
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
              const Icon(
                Icons.chevron_right,
                color: RefereeColors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
