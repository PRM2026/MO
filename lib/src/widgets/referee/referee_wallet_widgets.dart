import 'package:flutter/material.dart';

import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../models/referee_wallet_data.dart';
import 'referee_glass_card.dart';

class RefereeTournamentContextCard extends StatelessWidget {
  const RefereeTournamentContextCard({
    super.key,
    required this.tournament,
  });

  final RefereeWalletTournamentContext tournament;

  @override
  Widget build(BuildContext context) {
    return RefereeGlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.emoji_events_outlined, color: RefereeColors.tertiary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GIẢI ĐẤU HIỆN TẠI',
                  style: AppTypography.labelCaps(
                    RefereeColors.onSurfaceVariant,
                  ).copyWith(fontSize: 11, letterSpacing: 0.4),
                ),
                Text(
                  tournament.tournamentName,
                  style: AppTypography.headlineSm(RefereeColors.onSurface)
                      .copyWith(fontSize: 22, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: RefereeColors.tertiary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: RefereeColors.tertiary.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              tournament.phaseLabel,
              style: AppTypography.labelCaps(RefereeColors.tertiary)
                  .copyWith(fontSize: 11, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class RefereeBudgetOverviewSection extends StatelessWidget {
  const RefereeBudgetOverviewSection({super.key, required this.budget});

  final RefereeWalletBudgetOverview budget;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 720;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TotalBudgetCard(budget: budget),
            const SizedBox(height: 16),
            if (isWide)
              Row(
                children: [
                  Expanded(child: _FundCard(
                    label: 'Quỹ Giải thưởng',
                    amount: budget.prizeFundAmount,
                    icon: Icons.payments_outlined,
                    iconColor: RefereeColors.tertiary.withValues(alpha: 0.5),
                  )),
                  const SizedBox(width: 16),
                  Expanded(child: _FundCard(
                    label: 'Quỹ Thù lao & Phí',
                    amount: budget.feesFundAmount,
                    icon: Icons.work_outline,
                    iconColor: RefereeColors.secondary.withValues(alpha: 0.5),
                  )),
                ],
              )
            else
              Column(
                children: [
                  _FundCard(
                    label: 'Quỹ Giải thưởng',
                    amount: budget.prizeFundAmount,
                    icon: Icons.payments_outlined,
                    iconColor: RefereeColors.tertiary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  _FundCard(
                    label: 'Quỹ Thù lao & Phí',
                    amount: budget.feesFundAmount,
                    icon: Icons.work_outline,
                    iconColor: RefereeColors.secondary.withValues(alpha: 0.5),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }
}

class _TotalBudgetCard extends StatelessWidget {
  const _TotalBudgetCard({required this.budget});

  final RefereeWalletBudgetOverview budget;

  @override
  Widget build(BuildContext context) {
    return RefereeGlassCard(
      padding: const EdgeInsets.all(24),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -32,
            bottom: -32,
            child: Icon(
              Icons.account_balance_wallet_outlined,
              size: 120,
              color: RefereeColors.onSurface.withValues(alpha: 0.08),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: RefereeColors.tertiary, width: 4),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tổng ngân sách điều hành',
                    style: AppTypography.labelCaps(
                      RefereeColors.onSurfaceVariant,
                    ).copyWith(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      style: AppTypography.displayLg(RefereeColors.tertiary),
                      children: [
                        TextSpan(text: budget.totalBudget),
                        TextSpan(
                          text: ' VND',
                          style: AppTypography.headlineSm(
                            RefereeColors.tertiary,
                          ).copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: ColoredBox(
                      color: Colors.white.withValues(alpha: 0.05),
                      child: SizedBox(
                        height: 8,
                        child: Row(
                          children: [
                            Expanded(
                              flex: (budget.prizeFundRatio * 100).round(),
                              child: const ColoredBox(
                                color: RefereeColors.tertiary,
                              ),
                            ),
                            Expanded(
                              flex: (budget.feesFundRatio * 100).round(),
                              child: const ColoredBox(
                                color: RefereeColors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FundCard extends StatelessWidget {
  const _FundCard({
    required this.label,
    required this.amount,
    required this.icon,
    required this.iconColor,
  });

  final String label;
  final String amount;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return RefereeGlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.labelCaps(
                    RefereeColors.onSurfaceVariant,
                  ).copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  amount,
                  style: AppTypography.headlineSm(RefereeColors.onSurface)
                      .copyWith(fontSize: 22, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Icon(icon, color: iconColor, size: 28),
        ],
      ),
    );
  }
}

class RefereePendingDisbursementsSection extends StatelessWidget {
  const RefereePendingDisbursementsSection({
    super.key,
    required this.items,
    required this.pendingCount,
  });

  final List<PendingDisbursementItem> items;
  final int pendingCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  const Icon(
                    Icons.hourglass_empty,
                    color: RefereeColors.tertiary,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Chi trả chờ xử lý',
                      style: AppTypography.headlineSm(RefereeColors.onSurface)
                          .copyWith(fontSize: 22),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '$pendingCount mục đang chờ',
              style: AppTypography.labelCaps(RefereeColors.tertiary)
                  .copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 16),
        for (final item in items) ...[
          _PendingDisbursementTile(item: item),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _PendingDisbursementTile extends StatelessWidget {
  const _PendingDisbursementTile({required this.item});

  final PendingDisbursementItem item;

  @override
  Widget build(BuildContext context) {
    return RefereeGlassCard(
      padding: const EdgeInsets.all(16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: item.accentColor, width: 4),
          ),
          color: item.accentColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: RefereeColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Icon(item.icon, color: item.accentColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: AppTypography.bodyMd(RefereeColors.onSurface)
                          .copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      item.subtitle,
                      style: AppTypography.labelCaps(
                        RefereeColors.onSurfaceVariant,
                      ).copyWith(fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    item.amount,
                    style: AppTypography.headlineSm(RefereeColors.tertiary)
                        .copyWith(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  _DisbursementStatusBadge(status: item.status),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DisbursementStatusBadge extends StatefulWidget {
  const _DisbursementStatusBadge({required this.status});

  final DisbursementStatus status;

  @override
  State<_DisbursementStatusBadge> createState() =>
      _DisbursementStatusBadgeState();
}

class _DisbursementStatusBadgeState extends State<_DisbursementStatusBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.status == DisbursementStatus.readyToPay) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isReady = widget.status == DisbursementStatus.readyToPay;
    final color =
        isReady ? RefereeColors.successEmerald : RefereeColors.tertiary;
    final label = isReady ? 'Sẵn sàng chi trả' : 'Chờ phê duyệt';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isReady)
          FadeTransition(
            opacity: Tween<double>(begin: 0.4, end: 1).animate(
              CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
            ),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          )
        else
          const SizedBox(width: 6),
        const SizedBox(width: 4),
        Text(
          label.toUpperCase(),
          style: AppTypography.labelCaps(color).copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class RefereeWalletQuickActions extends StatelessWidget {
  const RefereeWalletQuickActions({
    super.key,
    required this.onApproveAll,
    required this.onExportReport,
    required this.isApproving,
  });

  final VoidCallback onApproveAll;
  final VoidCallback onExportReport;
  final bool isApproving;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton(
            onPressed: isApproving ? null : onApproveAll,
            style: FilledButton.styleFrom(
              backgroundColor: RefereeColors.tertiary,
              foregroundColor: RefereeColors.portalSurface,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isApproving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: RefereeColors.portalSurface,
                    ),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_outline, size: 28),
                      const SizedBox(height: 8),
                      Text(
                        'Phê duyệt chi trả toàn bộ',
                        textAlign: TextAlign.center,
                        style: AppTypography.labelCaps(
                          RefereeColors.portalSurface,
                        ).copyWith(fontSize: 13, letterSpacing: 0.2),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton(
            onPressed: onExportReport,
            style: OutlinedButton.styleFrom(
              foregroundColor: RefereeColors.tertiary,
              backgroundColor: RefereeColors.tertiary.withValues(alpha: 0.05),
              side: BorderSide(color: RefereeColors.tertiary),
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.description_outlined, size: 28),
                const SizedBox(height: 8),
                Text(
                  'Xuất báo cáo tài chính',
                  textAlign: TextAlign.center,
                  style: AppTypography.labelCaps(RefereeColors.tertiary)
                      .copyWith(fontSize: 13, letterSpacing: 0.2),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class RefereeTransactionHistorySection extends StatelessWidget {
  const RefereeTransactionHistorySection({
    super.key,
    required this.transactions,
  });

  final List<WalletTransactionItem> transactions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(Icons.history, color: RefereeColors.tertiary, size: 22),
            const SizedBox(width: 8),
            Text(
              'Lịch sử giao dịch',
              style: AppTypography.headlineSm(RefereeColors.onSurface)
                  .copyWith(fontSize: 22),
            ),
          ],
        ),
        const SizedBox(height: 16),
        RefereeGlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < transactions.length; i++) ...[
                _TransactionRow(item: transactions[i]),
                if (i < transactions.length - 1)
                  Divider(
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({required this.item});

  final WalletTransactionItem item;

  @override
  Widget build(BuildContext context) {
    final amountColor = item.direction == WalletTransactionDirection.inflow
        ? RefereeColors.tertiary
        : RefereeColors.successEmerald;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: AppTypography.bodyMd(RefereeColors.onSurface),
                ),
                Text(
                  item.meta,
                  style: AppTypography.labelCaps(
                    RefereeColors.onSurfaceVariant,
                  ).copyWith(fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            item.amountLabel,
            style: AppTypography.bodySm(amountColor)
                .copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
