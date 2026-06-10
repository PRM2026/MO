import 'package:flutter/material.dart';

import '../constants/referee_colors.dart';

enum DisbursementStatus {
  readyToPay,
  pendingApproval,
}

enum WalletTransactionDirection {
  outflow,
  inflow,
}

class RefereeWalletTournamentContext {
  const RefereeWalletTournamentContext({
    required this.tournamentName,
    required this.phaseLabel,
  });

  final String tournamentName;
  final String phaseLabel;
}

class RefereeWalletBudgetOverview {
  const RefereeWalletBudgetOverview({
    required this.totalBudget,
    required this.prizeFundAmount,
    required this.feesFundAmount,
    required this.prizeFundRatio,
    required this.feesFundRatio,
  });

  final String totalBudget;
  final String prizeFundAmount;
  final String feesFundAmount;
  final double prizeFundRatio;
  final double feesFundRatio;
}

class PendingDisbursementItem {
  const PendingDisbursementItem({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.status,
    required this.accentColor,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String amount;
  final DisbursementStatus status;
  final Color accentColor;
  final IconData icon;
}

class WalletTransactionItem {
  const WalletTransactionItem({
    required this.title,
    required this.meta,
    required this.amountLabel,
    required this.direction,
  });

  final String title;
  final String meta;
  final String amountLabel;
  final WalletTransactionDirection direction;
}

class RefereeWalletData {
  const RefereeWalletData({
    required this.tournament,
    required this.budget,
    required this.pendingDisbursements,
    required this.transactions,
    this.profileImageUrl,
  });

  final RefereeWalletTournamentContext tournament;
  final RefereeWalletBudgetOverview budget;
  final List<PendingDisbursementItem> pendingDisbursements;
  final List<WalletTransactionItem> transactions;
  final String? profileImageUrl;

  int get pendingCount => pendingDisbursements.length;

  static RefereeWalletData sample() {
    return RefereeWalletData(
      profileImageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBN3Taa3zquOwWlrwV7hhHeS3hpMVMB9DNrgxPAS0LD6coLLdwIlru-IpCSktWyV-jrhQtVJqbJhkRhnVrdkCzuf8665o6BW90WzkXtiqOH_wCz4bB4DQcFFRLAAq93GpR0SvzzJa9rGN-rTpw6EDJhhoHggzG7dnDs-0h23p_P-q2lJh_O3vcFN8A3Tpq_JW4ZtU9XZW0OONcJrOAqjw0ZljXU6aZwkNoOi9loDK5zaa7qp4GGLsOtuRt1Fd3l6nv6T_6YTZsv-Vnr',
      tournament: const RefereeWalletTournamentContext(
        tournamentName: 'Vietnam Derby Cup 2024',
        phaseLabel: 'Giai đoạn: Chung kết',
      ),
      budget: const RefereeWalletBudgetOverview(
        totalBudget: '500.000.000',
        prizeFundAmount: '350.000.000 VND',
        feesFundAmount: '150.000.000 VND',
        prizeFundRatio: 0.7,
        feesFundRatio: 0.3,
      ),
      pendingDisbursements: const [
        PendingDisbursementItem(
          title: 'Thưởng Hạng 1 - Thần Mã 07',
          subtitle: 'Kết quả xác nhận lúc 14:20',
          amount: '90.000.000',
          status: DisbursementStatus.readyToPay,
          accentColor: RefereeColors.successEmerald,
          icon: Icons.card_giftcard_outlined,
        ),
        PendingDisbursementItem(
          title: 'Thưởng Hạng 2 - Bạch Long',
          subtitle: 'Kết quả xác nhận lúc 14:21',
          amount: '37.500.000',
          status: DisbursementStatus.pendingApproval,
          accentColor: RefereeColors.statusRed,
          icon: Icons.card_giftcard_outlined,
        ),
        PendingDisbursementItem(
          title: 'Thù lao Trọng tài chính',
          subtitle: 'Dịch vụ điều hành chặng 4',
          amount: '10.000.000',
          status: DisbursementStatus.readyToPay,
          accentColor: RefereeColors.secondary,
          icon: Icons.badge_outlined,
        ),
      ],
      transactions: const [
        WalletTransactionItem(
          title: 'Chi trả Thưởng Chặng 3',
          meta: 'Hôm qua, 18:45 • ID: #TXN0984',
          amountLabel: '-125.000.000 VND',
          direction: WalletTransactionDirection.outflow,
        ),
        WalletTransactionItem(
          title: 'Phí xét nghiệm Horse-Doping',
          meta: '12/10/2024, 09:15 • ID: #TXN0982',
          amountLabel: '-15.000.000 VND',
          direction: WalletTransactionDirection.outflow,
        ),
        WalletTransactionItem(
          title: 'Bổ sung quỹ từ Ban tổ chức',
          meta: '10/10/2024, 14:00 • ID: #TXN0975',
          amountLabel: '+200.000.000 VND',
          direction: WalletTransactionDirection.inflow,
        ),
      ],
    );
  }
}
