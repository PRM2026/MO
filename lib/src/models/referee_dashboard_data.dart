import 'package:flutter/material.dart';

import '../models/jockey_dashboard_response.dart';
import '../models/referee_dashboard_response.dart';
import '../models/referee_race_response.dart';
import '../utils/currency_format.dart';
import '../utils/date_format.dart';

enum RefereeRaceStatus { live, pending, scheduled }

class RefereeRaceDetailRow {
  const RefereeRaceDetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;
}

class RefereeRaceItem {
  const RefereeRaceItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.status,
    required this.details,
    required this.actionLabel,
    this.actionEnabled = true,
    this.actionFilled = true,
    this.highlighted = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final RefereeRaceStatus status;
  final List<RefereeRaceDetailRow> details;
  final String actionLabel;
  final bool actionEnabled;
  final bool actionFilled;
  final bool highlighted;

  String get statusLabel {
    switch (status) {
      case RefereeRaceStatus.live:
        return 'ĐANG DIỄN RA';
      case RefereeRaceStatus.pending:
        return 'CHỜ CHECK-IN';
      case RefereeRaceStatus.scheduled:
        return 'ĐÃ LÊN LỊCH';
    }
  }
}

class RefereeStatItem {
  const RefereeStatItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.suffix,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String? suffix;
}

class RefereeDashboardData {
  const RefereeDashboardData({
    required this.refereeName,
    required this.welcomeMessage,
    required this.stats,
    required this.alertTitle,
    required this.alertMessage,
    required this.races,
    this.profileImageUrl,
    this.showAlert = false,
  });

  final String refereeName;
  final String welcomeMessage;
  final List<RefereeStatItem> stats;
  final String alertTitle;
  final String alertMessage;
  final List<RefereeRaceItem> races;
  final String? profileImageUrl;
  final bool showAlert;

  static const _defaultRaceImage =
      'https://images.unsplash.com/photo-1553284965-83fd3e82fa5a?auto=format&fit=crop&w=900&q=80';

  factory RefereeDashboardData.fromApi({
    required RefereeDashboardResponse dashboard,
    required List<RefereeRaceResponse> assignedRaces,
    required int violationCount,
    String? profileImageUrl,
  }) {
    final account = dashboard.account;
    final refereeName = _firstNonEmpty([
      _readString(account['fullName']),
      _readString(account['username']),
      'Trọng tài',
    ]);

    final todayCount = dashboard.summaryInt('todayRaceCount');
    final checkInRaceCount = dashboard.summaryInt('checkInRaceCount');
    final walletBalance = dashboard.walletAvailableBalance;

    final welcomeMessage = todayCount > 0
        ? 'Hôm nay bạn có $todayCount cuộc đua cần điều hành. Vui lòng kiểm tra các cảnh báo điều hành.'
        : 'Hệ thống đã sẵn sàng. Hiện chưa có cuộc đua nào được giao hôm nay.';

    final alert = _primaryAlert(dashboard.alerts);
    final racesById = {
      for (final race in assignedRaces)
        if (race.id != null) race.id!: race,
    };

    final upcomingRaces = dashboard.upcoming
        .map((item) => _raceFromDashboardItem(item, racesById))
        .whereType<RefereeRaceItem>()
        .toList();

    final fallbackRaces = assignedRaces
        .take(3)
        .map(_raceFromAssignedRace)
        .toList();

    return RefereeDashboardData(
      refereeName: refereeName,
      welcomeMessage: welcomeMessage,
      profileImageUrl: profileImageUrl,
      stats: [
        RefereeStatItem(
          icon: Icons.dashboard_outlined,
          iconColor: RefereeStatColors.gold,
          label: 'Cuộc đua hôm nay',
          value: _formatCount(todayCount),
        ),
        RefereeStatItem(
          icon: Icons.sports_score_outlined,
          iconColor: RefereeStatColors.gold,
          label: 'Chờ check-in',
          value: _formatCount(checkInRaceCount),
        ),
        RefereeStatItem(
          icon: Icons.report_problem_outlined,
          iconColor: RefereeStatColors.red,
          label: 'Vi phạm đã ghi',
          value: _formatCount(violationCount),
        ),
        RefereeStatItem(
          icon: Icons.account_balance_wallet_outlined,
          iconColor: RefereeStatColors.emerald,
          label: 'Số dư ví',
          value: formatVndCompact(walletBalance),
          suffix: 'VND',
        ),
      ],
      showAlert: alert != null,
      alertTitle: alert?.title ?? '',
      alertMessage: alert?.message ?? '',
      races: upcomingRaces.isNotEmpty ? upcomingRaces : fallbackRaces,
    );
  }

  static RefereeDashboardData sample() {
    return RefereeDashboardData(
      refereeName: 'Nguyễn Văn A',
      welcomeMessage:
          'Hệ thống đã sẵn sàng cho các lượt đua hôm nay. Vui lòng kiểm tra các cảnh báo điều hành.',
      profileImageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuB4MUAh-TtPnmQ2BojiY4F1yBYWQIbykm0EPNrTaEhYu3xyEqqCvhhLnTBX0F9WAK9Mgkh9KPFxltbLtJM0Oh556oxJ-d3WTEDRZWH6RefFNMoqcu4ehuPzdzjECx8tRaBbivzx2I7F5XEQ9EECAdyplC2MrGoonBu9Td-c8kd3p9LN534fWZvg9gOTSORZQznBXfkPVWRkcaVsUyd5i2zkTpkHkPScc5riQ9Yucu7JBcVcsanhaaQxykeDlDgm3p7NBXVteKd2f7E',
      alertTitle: 'Cảnh báo vận hành',
      alertMessage:
          'Cuộc đua #105 (Vòng loại 3) sắp bắt đầu trong 5 phút nữa. Vui lòng xác nhận danh sách thi đấu.',
      showAlert: true,
      stats: const [
        RefereeStatItem(
          icon: Icons.dashboard_outlined,
          iconColor: RefereeStatColors.gold,
          label: 'Cuộc đua hôm nay',
          value: '12',
        ),
        RefereeStatItem(
          icon: Icons.sports_score_outlined,
          iconColor: RefereeStatColors.gold,
          label: 'Chờ check-in',
          value: '04',
        ),
        RefereeStatItem(
          icon: Icons.flag_outlined,
          iconColor: RefereeStatColors.red,
          label: 'Chờ nhập kết quả',
          value: '02',
        ),
        RefereeStatItem(
          icon: Icons.account_balance_wallet_outlined,
          iconColor: RefereeStatColors.emerald,
          label: 'Số dư ví',
          value: '24.5M',
          suffix: 'VND',
        ),
      ],
      races: const [
        RefereeRaceItem(
          id: '105',
          title: 'Cuộc đua #105',
          subtitle: 'Vòng loại 3 • Sân vận động Quốc gia',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuCnHXYmzfno0ofw7SNb7xcXT_iUI0TgIOaoX6qyeWJzXRjaMPbgYmx432lWLBzpq2eQhX6PrGZRKwkBmQ1joaNBu-oj0ZkocYrF2EZs6P7ZsOa0G6BIjoYc-Y8BS22SN0oyfQmij0xmYWSBdiG9vapNEXZaENoCxzyRnJa4UT6LIfZcinszm2pIzToP-FRMoMuhMrMxPjvOC0zo3C6T2wlGDLTa-1vrfEqTzmIJWAsbUmc7K43au-fIrMtPoYqv7JHgOBGP7iDU-Qc',
          status: RefereeRaceStatus.live,
          highlighted: true,
          details: [
            RefereeRaceDetailRow(label: 'Tổng số ngựa:', value: '08'),
            RefereeRaceDetailRow(
              label: 'Trọng tài chính:',
              value: 'Nguyễn Văn A',
            ),
          ],
          actionLabel: 'Tiếp tục điều hành',
        ),
        RefereeRaceItem(
          id: '104',
          title: 'Cuộc đua #104',
          subtitle: 'Chung kết Ngày • Sân Phú Thọ',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuDfGCJPCxYiCao_AXUazgzQKFrUUbPvMy2Tk_r1-oCSlWCzoFHF8rNOA84aJx7cJwYelZbY637Cwnr5UPS5Zsgf-73YgOVFqtqlvj6uFF5nKdMq2MdgqrFFGezN6-n5Id5oxn0dUja1ToBuB4zgPNEqbB0WJoktCTRMGH0MCL43A0KmNt3Du1ZMVeUQLUFWbDzdCeIwH0UEyMGeIGrKtGd-qeNCI3kDMq0JW0GqQAZwgsGcT-1U6w82jScAqELo5k2N2bld_YnAEeo',
          status: RefereeRaceStatus.pending,
          actionFilled: false,
          details: [
            RefereeRaceDetailRow(label: 'Tổng số ngựa:', value: '12'),
            RefereeRaceDetailRow(
              label: 'Thời gian kết thúc:',
              value: '14:30 Today',
            ),
          ],
          actionLabel: 'Xem kết quả',
        ),
        RefereeRaceItem(
          id: '106',
          title: 'Cuộc đua #106',
          subtitle: 'Vòng loại 4 • Sân vận động Mỹ Đình',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuD4NQP1BrnF7qdX_C5_LHHd1NwkOIZEzmu6PAhfn9cA1hRosdQI4OurIYczDqA2OcnwBbTE3p1hMCN3ymy65qoTgMlJVYr7dtxBPt2Czwp3UJ94iLyIGefLMEYtoibmIq7_eaGk4OjmTonds6q0GXkjVgzb2ABcvhkDXlVmnJyvFRcUQ9_v0KohdhZ6gsYRbeZmF2vf7pHvv5oaOccN7OlHGkhxo150pCKcGYUHegcdkUmvZiixn-h4mvVrO-SjaJR4YvspkXhj3-c',
          status: RefereeRaceStatus.scheduled,
          actionFilled: false,
          actionEnabled: false,
          details: [
            RefereeRaceDetailRow(label: 'Bắt đầu lúc:', value: '16:45 Today'),
            RefereeRaceDetailRow(
              label: 'Giải thưởng:',
              value: '50,000,000 VND',
              valueColor: Color(0xFF10B981),
            ),
          ],
          actionLabel: 'Chưa thể bắt đầu',
        ),
      ],
    );
  }
}

class _RefereeDashboardAlert {
  const _RefereeDashboardAlert({required this.title, required this.message});

  final String title;
  final String message;
}

_RefereeDashboardAlert? _primaryAlert(
  List<JockeyDashboardItemResponse> alerts,
) {
  if (alerts.isEmpty) return null;

  final alert = alerts.first;
  final type = alert.type?.trim().toUpperCase() ?? '';
  final count = int.tryParse(alert.status?.trim() ?? '') ?? 0;

  final title = switch (type) {
    'REFEREE_CHECK_IN' => 'Cuộc đua chờ check-in',
    'REFEREE_RESULT_ENTRY' => 'Cuộc đua chờ nhập kết quả',
    _ => _readString(alert.title) ?? 'Cảnh báo điều hành',
  };

  final message = count > 0
      ? 'Hiện có $count cuộc đua cần xử lý.'
      : (_readString(alert.title) ??
            'Vui lòng kiểm tra danh sách cuộc đua được giao.');

  return _RefereeDashboardAlert(title: title, message: message);
}

RefereeRaceItem? _raceFromDashboardItem(
  JockeyDashboardItemResponse item,
  Map<String, RefereeRaceResponse> racesById,
) {
  final id = item.id;
  if (id != null) {
    final race = racesById['$id'];
    if (race != null) return _raceFromAssignedRace(race);
  }

  final title = _readString(item.title);
  if (title == null || title.isEmpty) return null;

  final status = _readString(item.status)?.toUpperCase() ?? '';
  return RefereeRaceItem(
    id: '${item.id ?? title}',
    title: title,
    subtitle: formatDisplayDateTime(item.at?.toIso8601String()),
    imageUrl: RefereeDashboardData._defaultRaceImage,
    status: _mapRaceStatus(status),
    highlighted: status == 'ONGOING',
    details: [
      RefereeRaceDetailRow(
        label: 'Trạng thái:',
        value: _raceStatusLabel(status),
      ),
      RefereeRaceDetailRow(
        label: 'Bắt đầu lúc:',
        value: formatDisplayDateTime(item.at?.toIso8601String()),
      ),
    ],
    actionLabel: _actionLabel(status),
    actionEnabled: status == 'ONGOING' || status == 'SCHEDULED',
    actionFilled: status == 'ONGOING' || status == 'SCHEDULED',
  );
}

RefereeRaceItem _raceFromAssignedRace(RefereeRaceResponse race) {
  final status = race.status?.toUpperCase() ?? '';
  final subtitleParts = [
    if (race.distance?.trim().isNotEmpty == true) race.distance!.trim(),
    if (race.venueName?.trim().isNotEmpty == true) race.venueName!.trim(),
    if (race.provinceName?.trim().isNotEmpty == true) race.provinceName!.trim(),
  ];

  return RefereeRaceItem(
    id: '${race.id ?? race.name}',
    title: _firstNonEmpty([race.name, 'Cuộc đua']),
    subtitle: subtitleParts.isEmpty ? '—' : subtitleParts.join(' • '),
    imageUrl: RefereeDashboardData._defaultRaceImage,
    status: _mapRaceStatus(status),
    highlighted: status == 'ONGOING',
    details: [
      RefereeRaceDetailRow(
        label: 'Tổng số ngựa:',
        value: '${race.participantCount ?? 0}',
      ),
      if (race.refereeUsername?.trim().isNotEmpty == true)
        RefereeRaceDetailRow(
          label: 'Trọng tài chính:',
          value: race.refereeUsername!.trim(),
        ),
      RefereeRaceDetailRow(
        label: status == 'ONGOING' ? 'Kết thúc dự kiến:' : 'Bắt đầu lúc:',
        value: formatDisplayDateTime(
          (status == 'ONGOING' ? race.scheduledEndAt : race.scheduledStartAt)
              ?.toIso8601String(),
        ),
      ),
    ],
    actionLabel: _actionLabel(status),
    actionEnabled: status == 'ONGOING' || status == 'SCHEDULED',
    actionFilled: status == 'ONGOING' || status == 'SCHEDULED',
  );
}

RefereeRaceStatus _mapRaceStatus(String status) {
  return switch (status) {
    'ONGOING' => RefereeRaceStatus.live,
    'SCHEDULED' => RefereeRaceStatus.pending,
    _ => RefereeRaceStatus.scheduled,
  };
}

String _raceStatusLabel(String status) {
  return switch (status) {
    'ONGOING' => 'Đang diễn ra',
    'SCHEDULED' => 'Chờ check-in',
    'RESULT_CONFIRMED' => 'Đã xác nhận kết quả',
    'REGISTRATION_CLOSED' => 'Đóng đăng ký',
    'OPEN_REGISTRATION' => 'Mở đăng ký',
    'PUBLISHED' => 'Đã công bố',
    'DRAFT' => 'Nháp',
    'CANCELLED' => 'Đã hủy',
    _ => 'Sắp diễn ra',
  };
}

String _actionLabel(String status) {
  return switch (status) {
    'ONGOING' => 'Tiếp tục điều hành',
    'SCHEDULED' => 'Mở check-in',
    'RESULT_CONFIRMED' => 'Xem kết quả',
    _ => 'Chi tiết',
  };
}

String _formatCount(int value) => value.toString().padLeft(2, '0');

String _firstNonEmpty(List<String?> values) {
  for (final value in values) {
    final trimmed = value?.trim();
    if (trimmed != null && trimmed.isNotEmpty) return trimmed;
  }
  return 'Trọng tài';
}

String? _readString(Object? value) {
  if (value == null) return null;
  if (value is String) return value;
  return value.toString();
}

abstract final class RefereeStatColors {
  static const gold = Color(0xFFF6BE39);
  static const red = Color(0xFFEA212E);
  static const emerald = Color(0xFF10B981);
}
