import 'package:flutter/material.dart';

import '../constants/referee_colors.dart';
import 'user_profile.dart';

class OwnerProfileSettingItem {
  const OwnerProfileSettingItem({
    required this.title,
    required this.icon,
    required this.iconColor,
    this.trailingLabel,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final String? trailingLabel;
}

class OwnerProfileData {
  const OwnerProfileData({
    required this.fullName,
    required this.roleLabel,
    required this.settings,
    this.id,
    this.username,
    this.email,
    this.avatarUrl,
  });

  final int? id;
  final String fullName;
  final String? username;
  final String? email;
  final String roleLabel;
  final String? avatarUrl;
  final List<OwnerProfileSettingItem> settings;

  String? get displayId => id == null ? null : '$id';

  factory OwnerProfileData.fromUserProfile(UserProfile user) {
    final fullName = _firstNonEmpty([
      user.fullName,
      user.username,
      user.email,
      'Chủ ngựa',
    ]);

    return OwnerProfileData(
      id: user.id,
      fullName: fullName,
      username: _emptyToNull(user.username),
      email: _emptyToNull(user.email),
      roleLabel: _roleLabel(user.normalizedRole),
      avatarUrl: _emptyToNull(user.avatarUrl),
      settings: const [
        OwnerProfileSettingItem(
          title: 'Lời mời jockey',
          icon: Icons.mail_outline,
          iconColor: RefereeColors.championshipGold,
        ),
        OwnerProfileSettingItem(
          title: 'Jockey đã nhận lời',
          icon: Icons.groups_outlined,
          iconColor: RefereeColors.successEmerald,
        ),
        OwnerProfileSettingItem(
          title: 'Đăng ký cuộc đua',
          icon: Icons.how_to_reg_outlined,
          iconColor: RefereeColors.successEmerald,
        ),
        OwnerProfileSettingItem(
          title: 'Ví & thanh toán',
          icon: Icons.account_balance_wallet_outlined,
          iconColor: RefereeColors.championshipGold,
        ),
        OwnerProfileSettingItem(
          title: 'Thông báo',
          icon: Icons.notifications_outlined,
          iconColor: RefereeColors.secondary,
        ),
        OwnerProfileSettingItem(
          title: 'Bảo mật & Mật khẩu',
          icon: Icons.security_outlined,
          iconColor: RefereeColors.secondary,
        ),
      ],
    );
  }
}

String _firstNonEmpty(List<String?> values) {
  for (final value in values) {
    final normalized = _emptyToNull(value);
    if (normalized != null) return normalized;
  }
  return '';
}

String? _emptyToNull(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}

String _roleLabel(String role) {
  return switch (role) {
    'OWNER' => 'Chủ ngựa',
    _ => role.isEmpty ? 'Chủ ngựa' : role,
  };
}
