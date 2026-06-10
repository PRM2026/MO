import 'package:flutter/material.dart';

import '../constants/referee_colors.dart';

enum JockeyHorseStatus {
  ready,
  training,
  resting,
}

class JockeyDashboardStat {
  const JockeyDashboardStat({
    required this.label,
    required this.value,
    this.suffix,
    this.trend,
    this.highlight = false,
    this.accentBorder = false,
    this.subLabel,
  });

  final String label;
  final String value;
  final String? suffix;
  final String? trend;
  final bool highlight;
  final bool accentBorder;
  final String? subLabel;
}

class JockeyAssignedHorse {
  const JockeyAssignedHorse({
    required this.name,
    required this.imageUrl,
    required this.speed,
    required this.stamina,
    required this.status,
  });

  final String name;
  final String imageUrl;
  final String speed;
  final String stamina;
  final JockeyHorseStatus status;
}

class JockeyRecentResult {
  const JockeyRecentResult({
    required this.rank,
    required this.eventName,
    required this.detail,
    required this.isWinner,
  });

  final int rank;
  final String eventName;
  final String detail;
  final bool isWinner;
}

class JockeyDashboardData {
  const JockeyDashboardData({
    required this.greeting,
    required this.jockeyName,
    required this.stats,
    required this.alertTitle,
    required this.alertMessage,
    required this.horses,
    required this.recentResults,
    required this.motivationQuote,
    required this.motivationImageUrl,
    this.profileImageUrl,
  });

  final String greeting;
  final String jockeyName;
  final List<JockeyDashboardStat> stats;
  final String alertTitle;
  final String alertMessage;
  final List<JockeyAssignedHorse> horses;
  final List<JockeyRecentResult> recentResults;
  final String motivationQuote;
  final String motivationImageUrl;
  final String? profileImageUrl;

  static JockeyDashboardData sample({String? fullName}) {
    final name = fullName?.trim().isNotEmpty == true
        ? fullName!.trim()
        : 'Minh Tuấn';

    return JockeyDashboardData(
      greeting: 'CHÀO BUỔI SÁNG',
      jockeyName: 'Jockey $name',
      profileImageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuB9ruJfuXYj6y6AczE5jrGRy1ejWKmxtUnbLvbn0DUQeLLY4e0ZdhVQ3EIKPslaawNq4QL-sq3obeKku3EMVnuCLOG2D6nfDfEivgxxkDUajx-Ruh5o2th_PRWqhQKvnPgZ6cKTOLMGwc3GLjW0E4PjUmx3qwhSitwlVnFOw52nUZuW2tXgbHoNuJi1FuRSMGHNQWwhnomdjdOkFGzIeuJi5sdUL_fpMgUuJl0iEOAKv0KtGa9CVpoxCLZlRZFNW7cKp9POsHFjLcs',
      stats: const [
        JockeyDashboardStat(
          label: 'Xếp hạng mùa',
          value: '#12',
          trend: '↑2',
          highlight: true,
          accentBorder: true,
        ),
        JockeyDashboardStat(
          label: 'Tỉ lệ thắng',
          value: '92%',
        ),
        JockeyDashboardStat(
          label: 'Giải sắp tới',
          value: '3',
        ),
        JockeyDashboardStat(
          label: 'Thu nhập',
          value: '150M',
          subLabel: 'VND',
          highlight: true,
        ),
      ],
      alertTitle: 'Cảnh báo quan trọng',
      alertMessage:
          'Bạn có lịch kiểm tra y tế bắt buộc vào lúc 09:00 Thứ Hai tới.',
      horses: const [
        JockeyAssignedHorse(
          name: 'Hắc Phong',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuDtiNPBWozvysd2Bfd0fDdNXqmLgNcuDTB5HFa50RgUYoyA95jSzzAPn5LDpVHIevC3cT9LSEh-NWDfh-kjOQcX02VcTc4XnnMQupKWb-z4dp95_f2TQRRcyS020zyT34d2mCiCfo5Zfpouy7MBilM3ebXlE0TfMVoxNv0UQvgGMqjyeHwIZfLT3QjblGhLr0LTlGob0NbN_mPkbajM2KGV6vTJuMtejftQuOlRpOAV5j0XYs-rFXmiOPVNwDqh0nQV9zmRdKTI7Z4',
          speed: '9.2',
          stamina: '8.5',
          status: JockeyHorseStatus.ready,
        ),
        JockeyAssignedHorse(
          name: 'Silver Storm',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuAXrCPy1RN_V_nICooz7TUTY8hG1EPN0F9AkANcgOZJhiDtUidJ4qU-zq-XgMtDCaGF9HMyonPsaEfezFnT2i9SCEbFL_ksRcVZppOam_5gb2cKXOxWuzrr0qfa063SOdTWGW1O4YAj0mmakNwTHn3iOEY6pJMUvmsW9F5MWzDfI4R-ifb3ZGDHtmKo8tB7jsscHyfmYLursJXAEhJDVXJdkwjEs7mYPvMglanFsNo5AWIK3xYIVRrTOnJE0Jw-hzafqSDEoEWgmpM',
          speed: '8.8',
          stamina: '9.4',
          status: JockeyHorseStatus.training,
        ),
        JockeyAssignedHorse(
          name: 'Fire Ember',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuAj1AIsJk_uUczoUYFAolp6OY9jbQlY6biyBq7tkmAVMB4Y-O5T5ivTutL9jUYL9cmckDLIFjcJz-iDDylDqBeUNzq3EmbWhIlHWU0y7zytCRVxxUyobkzGMP-P4TRxJWSsQYsSl0RT9wKxNdpDrQ4YTUHdLzp3gw3TL7FMbYzWcdOXaDOGSPGxtRZY4bYZ7rCmfCjd3HRPD5_ZJ2S3a8pHa5qEa6XaAwJvU9wJYEnLnV2kqVbCOUfORkT6pnlCHhxTgaQz82-ot54',
          speed: '8.5',
          stamina: '8.0',
          status: JockeyHorseStatus.resting,
        ),
      ],
      recentResults: const [
        JockeyRecentResult(
          rank: 1,
          eventName: 'Grand Prix Hanoi',
          detail: 'Với Hắc Phong • 2.4km',
          isWinner: true,
        ),
        JockeyRecentResult(
          rank: 2,
          eventName: 'Saigon Cup',
          detail: 'Với Silver Storm • 1.8km',
          isWinner: false,
        ),
        JockeyRecentResult(
          rank: 1,
          eventName: 'Da Nang Derby',
          detail: 'Với Hắc Phong • 3.2km',
          isWinner: true,
        ),
      ],
      motivationQuote: '"Tốc độ là kỹ năng, nhưng bền bỉ là đẳng cấp."',
      motivationImageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDy3N5UQu46zzwvJlNmV-QqjtwWqyettxm0wiv20gtFnGLa0G-2ZbjqXTMjfKT-DUzCLDN3JB0mXeR694o5RZ9ulGLzvgLgWZbUktJ6b2SCJ5HDOH85hEgxC4WUT2DdMp-ENqctMlobARrU5XU3VACJQooUd3itdHeXvN5-cbFmuWR0Qci7eRnojhFJsAC3XbBGVWHxgTaD1BtAYwYKjYI0UHtk7uupMyw6j30QjUdv_0xK7MZt-k9dXlZvDizzs6jsACbnfpKLEWw',
    );
  }

  static String statusLabel(JockeyHorseStatus status) {
    return switch (status) {
      JockeyHorseStatus.ready => 'SẴN SÀNG',
      JockeyHorseStatus.training => 'ĐANG HUẤN LUYỆN',
      JockeyHorseStatus.resting => 'NGHỈ NGƠI',
    };
  }

  static Color statusColor(JockeyHorseStatus status) {
    return switch (status) {
      JockeyHorseStatus.ready => RefereeColors.successEmerald,
      JockeyHorseStatus.training => RefereeColors.championshipGold,
      JockeyHorseStatus.resting => RefereeColors.onSurface,
    };
  }
}
