import 'package:flutter/material.dart';

import '../constants/referee_colors.dart';

class RefereeProfileStat {
  const RefereeProfileStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    this.hoverBorderColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final Color? hoverBorderColor;
}

class RefereeProfileSettingItem {
  const RefereeProfileSettingItem({
    required this.title,
    required this.icon,
    required this.iconColor,
    this.trailingLabel,
    this.onTap,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final String? trailingLabel;
  final VoidCallback? onTap;
}

class RefereeProfileData {
  const RefereeProfileData({
    required this.fullName,
    required this.refereeId,
    required this.rankLabel,
    required this.stats,
    required this.settings,
    this.avatarUrl,
    this.isOnline = true,
  });

  final String fullName;
  final String refereeId;
  final String rankLabel;
  final List<RefereeProfileStat> stats;
  final List<RefereeProfileSettingItem> settings;
  final String? avatarUrl;
  final bool isOnline;

  static RefereeProfileData sample({
    String fullName = 'Nguyễn Văn A',
    String? avatarUrl,
  }) {
    return RefereeProfileData(
      fullName: fullName,
      refereeId: 'REF-2024-001',
      rankLabel: 'Trọng tài cấp cao',
      avatarUrl: avatarUrl ??
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCNNgHkDpyLfu9TuLH0RmMsfTtEWzP3IJHBdZUl3kkfBZj-x5l4ocUCUhsewyvk01nHsG3-df3viqyWb03eKJpR5DtOznmPgVGGcGr5jc-nqg3bdQnJfbtz-8xS7iJHgx6xxvFhav_LRMu9BAhJfmZuVoloGWyxu1KVoX0vWaQHjzymRwjavBjIoyTTBRL8j1rMXcHorJIXo0ojc2TA2GGm2g6axn15-oBVqjb4uF2dACGs06Z8J7CJPT0qjbTiu3045SvtPv5mhG4m',
      stats: const [
        RefereeProfileStat(
          label: 'Số trận đã xử lý',
          value: '156',
          icon: Icons.sports_score,
          iconColor: RefereeColors.tertiary,
          iconBackgroundColor: Color(0x1AF6BE39),
          hoverBorderColor: RefereeColors.tertiary,
        ),
        RefereeProfileStat(
          label: 'Vi phạm đã ghi nhận',
          value: '42',
          icon: Icons.gavel,
          iconColor: RefereeColors.statusRed,
          iconBackgroundColor: Color(0x1AEA212E),
          hoverBorderColor: RefereeColors.statusRed,
        ),
      ],
      settings: const [
        RefereeProfileSettingItem(
          title: 'Bảo mật & Mật khẩu',
          icon: Icons.security_outlined,
          iconColor: RefereeColors.secondary,
        ),
      ],
    );
  }
}
