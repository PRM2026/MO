import 'package:flutter/material.dart';

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
        return 'CHỜ XÁC NHẬN';
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
    required this.stats,
    required this.alertTitle,
    required this.alertMessage,
    required this.races,
    this.profileImageUrl,
  });

  final String refereeName;
  final List<RefereeStatItem> stats;
  final String alertTitle;
  final String alertMessage;
  final List<RefereeRaceItem> races;
  final String? profileImageUrl;

  static RefereeDashboardData sample() {
    return RefereeDashboardData(
      refereeName: 'Nguyễn Văn A',
      profileImageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuB4MUAh-TtPnmQ2BojiY4F1yBYWQIbykm0EPNrTaEhYu3xyEqqCvhhLnTBX0F9WAK9Mgkh9KPFxltbLtJM0Oh556oxJ-d3WTEDRZWH6RefFNMoqcu4ehuPzdzjECx8tRaBbivzx2I7F5XEQ9EECAdyplC2MrGoonBu9Td-c8kd3p9LN534fWZvg9gOTSORZQznBXfkPVWRkcaVsUyd5i2zkTpkHkPScc5riQ9Yucu7JBcVcsanhaaQxykeDlDgm3p7NBXVteKd2f7E',
      alertTitle: 'Cảnh báo vận hành',
      alertMessage:
          'Cuộc đua #105 (Vòng loại 3) sắp bắt đầu trong 5 phút nữa. Vui lòng xác nhận danh sách thi đấu.',
      stats: const [
        RefereeStatItem(
          icon: Icons.dashboard_outlined,
          iconColor: RefereeStatColors.gold,
          label: 'Giải đấu hôm nay',
          value: '12',
        ),
        RefereeStatItem(
          icon: Icons.sports_score_outlined,
          iconColor: RefereeStatColors.gold,
          label: 'Chờ xác nhận',
          value: '04',
        ),
        RefereeStatItem(
          icon: Icons.report_problem_outlined,
          iconColor: RefereeStatColors.red,
          label: 'Vi phạm gần đây',
          value: '08',
        ),
        RefereeStatItem(
          icon: Icons.account_balance_wallet_outlined,
          iconColor: RefereeStatColors.emerald,
          label: 'Số dư ví (VND)',
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

abstract final class RefereeStatColors {
  static const gold = Color(0xFFF6BE39);
  static const red = Color(0xFFEA212E);
  static const emerald = Color(0xFF10B981);
}
