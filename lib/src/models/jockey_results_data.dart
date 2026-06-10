import 'package:flutter/material.dart';

import '../constants/referee_colors.dart';

enum JockeyResultRank {
  first,
  second,
  other,
}

class JockeyResultsStatItem {
  const JockeyResultsStatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
    this.highlightValue = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;
  final bool highlightValue;
}

class JockeyFeaturedHorseCard {
  const JockeyFeaturedHorseCard({
    required this.name,
    required this.subtitle,
    required this.badgeLabel,
    required this.winRate,
    required this.topSpeed,
    required this.imageUrl,
  });

  final String name;
  final String subtitle;
  final String badgeLabel;
  final String winRate;
  final String topSpeed;
  final String imageUrl;
}

class JockeyRaceResultItem {
  const JockeyRaceResultItem({
    required this.id,
    required this.eventName,
    required this.trackInfo,
    required this.horseName,
    required this.jockeyName,
    required this.rank,
    required this.rankLabel,
    required this.finishTime,
    required this.prizeAmount,
  });

  final String id;
  final String eventName;
  final String trackInfo;
  final String horseName;
  final String jockeyName;
  final JockeyResultRank rank;
  final String rankLabel;
  final String finishTime;
  final String prizeAmount;

  Color get rankColor {
    return switch (rank) {
      JockeyResultRank.first => RefereeColors.championshipGold,
      JockeyResultRank.second => RefereeColors.secondary,
      JockeyResultRank.other => RefereeColors.onSurfaceVariant,
    };
  }
}

class JockeyResultsData {
  const JockeyResultsData({
    required this.stats,
    required this.chartHeights,
    required this.chartTrendLabel,
    required this.featuredHorse,
    required this.results,
    required this.totalResults,
    this.profileImageUrl,
  });

  final List<JockeyResultsStatItem> stats;
  final List<double> chartHeights;
  final String chartTrendLabel;
  final JockeyFeaturedHorseCard featuredHorse;
  final List<JockeyRaceResultItem> results;
  final int totalResults;
  final String? profileImageUrl;

  static JockeyResultsData sample() {
    return JockeyResultsData(
      profileImageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDkLB5jkaxAnb-1BaACS74YAhxqjUIhk9JvA2sQevctS0Yad-wsNYMBrCu-huTsx4ib7XX7A22sirN6O1hgAtKMKcLQtBIyFwUwx81uO45g_G1-4z3gorcF2ciZQPZusU1Rp9bS5cp5FSmWs0Xj5YJdbdkawYe-9sFrL5IefyavnUbsKvR4zXf-sUMFTXERx7r7FqKJ9TiNszdLZLWNwHO-wqBS7ucJg5AfAc37mBdNcQY7qjrg0XWbz0CGPCSKO4A1OfXz85TiO8c',
      stats: const [
        JockeyResultsStatItem(
          label: 'Tổng giải chạy',
          value: '148',
          icon: Icons.stadium_outlined,
          accentColor: RefereeColors.secondary,
        ),
        JockeyResultsStatItem(
          label: 'Số lần thắng',
          value: '32',
          icon: Icons.emoji_events_outlined,
          accentColor: RefereeColors.successEmerald,
        ),
        JockeyResultsStatItem(
          label: 'Lên bục',
          value: '84',
          icon: Icons.military_tech_outlined,
          accentColor: RefereeColors.tertiary,
        ),
        JockeyResultsStatItem(
          label: 'Tổng thưởng',
          value: '2,4 tỷ',
          icon: Icons.payments_outlined,
          accentColor: RefereeColors.championshipGold,
          highlightValue: true,
        ),
      ],
      chartHeights: const [0.35, 0.55, 0.45, 0.65, 0.85, 0.75, 0.95, 0.45, 0.65, 1.0],
      chartTrendLabel: '+12% so với tháng trước',
      featuredHorse: JockeyFeaturedHorseCard(
        name: 'Midnight Sovereign',
        subtitle: 'Ngựa xuất sắc nhất của Elite Stable',
        badgeLabel: 'MVP STABLE',
        winRate: '78%',
        topSpeed: '72 km/h',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuA383m4MNKRt87KISomlrOUoK5vjovAZ-HVhZC-4A65WXlPLTHGB2BgcHsrKPMIIJjnxHJSKzPhQIaAX_m9atpk6Nq7d9sqbn4jOifIKPjcpIez3RgPs5EbDYfBeBxLtoNmUs3BA0AxOE0_C_DR8cg_p7UnPikmC6OpRaS8Go-1Urt2k9O1zY_J7JmWebqOSirD8hdR7c-ma8VsyvOdDm5Bnp_DmD9fI065EFX3HlGxC1QLDz7gWu2iK8F6uUGchUGXJPc-86l-6c0',
      ),
      totalResults: 148,
      results: const [
        JockeyRaceResultItem(
          id: 'res-001',
          eventName: 'Grand Prix Dubai',
          trackInfo: 'Đường cát - 2400m',
          horseName: 'Shadow Runner',
          jockeyName: 'Minh Tuấn',
          rank: JockeyResultRank.first,
          rankLabel: 'Hạng 1',
          finishTime: '02:14.45',
          prizeAmount: '450.000.000 VND',
        ),
        JockeyRaceResultItem(
          id: 'res-002',
          eventName: 'Royal Ascot',
          trackInfo: 'Cỏ - 1600m',
          horseName: 'Silver Arrow',
          jockeyName: 'Minh Tuấn',
          rank: JockeyResultRank.second,
          rankLabel: 'Hạng 2',
          finishTime: '01:42.12',
          prizeAmount: '120.000.000 VND',
        ),
        JockeyRaceResultItem(
          id: 'res-003',
          eventName: 'Kentucky Derby',
          trackInfo: 'Đất - 2000m',
          horseName: 'Thunder Bolt',
          jockeyName: 'Minh Tuấn',
          rank: JockeyResultRank.other,
          rankLabel: 'Hạng 4',
          finishTime: '02:02.88',
          prizeAmount: '15.000.000 VND',
        ),
      ],
    );
  }
}
