import 'package:flutter/material.dart';

import '../constants/referee_colors.dart';

enum JockeyScheduleViewMode { calendar, list }

enum JockeyRaceScheduleStatus { pending, confirmed }

class JockeyScheduleDateItem {
  const JockeyScheduleDateItem({
    required this.monthLabel,
    required this.day,
    required this.dateKey,
    this.isSelected = false,
  });

  final String monthLabel;
  final int day;
  final String dateKey;
  final bool isSelected;
}

class JockeyRaceScheduleItem {
  const JockeyRaceScheduleItem({
    required this.id,
    required this.dateKey,
    required this.timeLabel,
    required this.eventName,
    required this.horseName,
    required this.venue,
    required this.laneLabel,
    required this.status,
    required this.imageUrl,
    this.isDimmed = false,
  });

  final String id;
  final String dateKey;
  final String timeLabel;
  final String eventName;
  final String horseName;
  final String venue;
  final String laneLabel;
  final JockeyRaceScheduleStatus status;
  final String imageUrl;
  final bool isDimmed;

  bool get isPending => status == JockeyRaceScheduleStatus.pending;
  bool get isConfirmed => status == JockeyRaceScheduleStatus.confirmed;
}

class JockeyScheduleData {
  const JockeyScheduleData({
    required this.dates,
    required this.races,
    this.profileImageUrl,
  });

  final List<JockeyScheduleDateItem> dates;
  final List<JockeyRaceScheduleItem> races;
  final String? profileImageUrl;

  static JockeyScheduleData sample() {
    return JockeyScheduleData(
      profileImageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDkLB5jkaxAnb-1BaACS74YAhxqjUIhk9JvA2sQevctS0Yad-wsNYMBrCu-huTsx4ib7XX7A22sirN6O1hgAtKMKcLQtBIyFwUwx81uO45g_G1-4z3gorcF2ciZQPZusU1Rp9bS5cp5FSmWs0Xj5YJdbdkawYe-9sFrL5IefyavnUbsKvR4zXf-sUMFTXERx7r7FqKJ9TiNszdLZLWNwHO-wqBS7ucJg5AfAc37mBdNcQY7qjrg0XWbz0CGPCSKO4A1OfXz85TiO8c',
      dates: const [
        JockeyScheduleDateItem(
          monthLabel: 'Th12',
          day: 15,
          dateKey: '2024-12-15',
          isSelected: true,
        ),
        JockeyScheduleDateItem(
          monthLabel: 'Th12',
          day: 16,
          dateKey: '2024-12-16',
        ),
        JockeyScheduleDateItem(
          monthLabel: 'Th12',
          day: 17,
          dateKey: '2024-12-17',
        ),
        JockeyScheduleDateItem(
          monthLabel: 'Th12',
          day: 18,
          dateKey: '2024-12-18',
        ),
        JockeyScheduleDateItem(
          monthLabel: 'Th12',
          day: 19,
          dateKey: '2024-12-19',
        ),
      ],
      races: const [
        JockeyRaceScheduleItem(
          id: 'race-001',
          dateKey: '2024-12-15',
          timeLabel: '15 Tháng 12, 14:30',
          eventName: 'Grand Prix Saigon',
          horseName: 'Silver Storm',
          venue: 'Sân vận động Phú Thọ',
          laneLabel: 'Lane 5',
          status: JockeyRaceScheduleStatus.pending,
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuDuNcqIj-KZiwIUCTOn7an6QgK6pt98OvCkEI3CjQvzsOtQ1imc5HaAlCK2jQvzIZbJ_BdqdLKqkXEBs9xessJWumlpHjGNExOxa2yWQv62wi6BMAYZ90wYWczg1xXHTfOOeUQr8_Xs3qcp8flkvGqjrV_GSVOVohOPV0zE2MbepwnOx9k-V481fEtyLAYZm8utPIJsz_wNqap9RxX1Kmlhl7TlQdlkdeTfz1QZgpUwYzP6qGWDUelFaNqb2eXyRSCKj87O6xtBUuA',
        ),
        JockeyRaceScheduleItem(
          id: 'race-002',
          dateKey: '2024-12-20',
          timeLabel: '20 Tháng 12, 10:15',
          eventName: 'Vietnam Derby',
          horseName: 'Midnight Sun',
          venue: 'Sân vận động Sóc Sơn',
          laneLabel: 'Lane 2',
          status: JockeyRaceScheduleStatus.confirmed,
          isDimmed: true,
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuAMMcl_-WCqTyl7Pe33BxPf28Xehj2DipnoZlloCXf0zwcflkGDwqXgda-NN5HZRHFPqksg3_c20m9eMDLKaROgmeFSoqkkNm6ah-vEj3klS4HMST_1W6Eyi7_bnMCtVNxh4xecwONTTMEsiwykQEV21B6y-NG-Dwdtg2gxTihkJGGlia-Zqp02Vs7C3f70RtFPPS9DPky1kssEMkMy7L3BfBbrx5e1S924xEBbRixwq2f5Za1Yy-GudZjbDiICMML4K2z7EAA2AUA',
        ),
      ],
    );
  }

  static String statusLabel(JockeyRaceScheduleStatus status) {
    return switch (status) {
      JockeyRaceScheduleStatus.pending => 'Chưa xác nhận',
      JockeyRaceScheduleStatus.confirmed => 'Đã xác nhận',
    };
  }

  static Color statusColor(JockeyRaceScheduleStatus status) {
    return switch (status) {
      JockeyRaceScheduleStatus.pending => RefereeColors.statusRed,
      JockeyRaceScheduleStatus.confirmed => RefereeColors.successEmerald,
    };
  }
}
