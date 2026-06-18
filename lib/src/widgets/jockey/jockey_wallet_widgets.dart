import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../models/deposit_order_response.dart';
import '../../models/wallet_response.dart';
import '../../models/wallet_transaction_response.dart';
import '../../models/withdrawal_response.dart';
import '../../utils/currency_format.dart';
import '../../utils/date_format.dart';
import '../../utils/wallet_labels.dart';
import '../../viewmodels/jockey_wallet_viewmodel.dart';
import '../referee/referee_glass_card.dart';
import 'jockey_state_widgets.dart';

class JockeyWalletBalanceCard extends StatelessWidget {
  const JockeyWalletBalanceCard({
    super.key,
    required this.wallet,
    required this.onDeposit,
    required this.onWithdraw,
  });

  final WalletResponse wallet;
  final VoidCallback? onDeposit;
  final VoidCallback? onWithdraw;

  @override
  Widget build(BuildContext context) {
    return RefereeGlassCard(
      highlighted: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'SỐ DƯ KHẢ DỤNG',
                  style: AppTypography.labelCaps(
                    RefereeColors.onSurfaceVariant,
                  ),
                ),
              ),
              _StatusBadge(
                label: walletStatusLabel(wallet.status),
                active: wallet.isActive,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${formatVnd(wallet.availableBalance)} ${wallet.currency}',
            key: const Key('jockey-wallet-available'),
            style: AppTypography.displayLg(
              RefereeColors.championshipGold,
            ).copyWith(fontSize: 32),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _BalanceValue(
                  label: 'Đang giữ',
                  value: wallet.holdBalance,
                  currency: wallet.currency,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _BalanceValue(
                  label: 'Tổng số dư',
                  value: wallet.totalBalance,
                  currency: wallet.currency,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            children: [
              FilledButton.icon(
                key: const Key('jockey-wallet-deposit'),
                onPressed: onDeposit,
                icon: const Icon(Icons.add_card_outlined),
                label: const Text('Nạp tiền'),
              ),
              OutlinedButton.icon(
                key: const Key('jockey-wallet-withdraw'),
                onPressed: onWithdraw,
                icon: const Icon(Icons.account_balance_outlined),
                label: const Text('Rút tiền'),
              ),
            ],
          ),
          if (!wallet.isActive) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Ví không hoạt động nên các thao tác tài chính đang bị khóa.',
              style: AppTypography.bodySm(RefereeColors.statusRed),
            ),
          ],
        ],
      ),
    );
  }
}

class JockeyWalletTabs extends StatelessWidget {
  const JockeyWalletTabs({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final JockeyWalletTab selected;
  final ValueChanged<JockeyWalletTab> onSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final showIcons = constraints.maxWidth >= 520;
        return SegmentedButton<JockeyWalletTab>(
          segments: [
            ButtonSegment(
              value: JockeyWalletTab.transactions,
              icon: showIcons ? const Icon(Icons.receipt_long_outlined) : null,
              label: Text(
                'Giao dịch',
                key: Key('jockey-wallet-tab-transactions'),
              ),
            ),
            ButtonSegment(
              value: JockeyWalletTab.deposits,
              icon: showIcons ? const Icon(Icons.add_card_outlined) : null,
              label: Text('Lệnh nạp', key: Key('jockey-wallet-tab-deposits')),
            ),
            ButtonSegment(
              value: JockeyWalletTab.withdrawals,
              icon: showIcons
                  ? const Icon(Icons.account_balance_outlined)
                  : null,
              label: Text(
                'Rút tiền',
                key: Key('jockey-wallet-tab-withdrawals'),
              ),
            ),
          ],
          selected: {selected},
          onSelectionChanged: (values) => onSelected(values.first),
          showSelectedIcon: false,
        );
      },
    );
  }
}

class JockeyWalletTabContent extends StatelessWidget {
  const JockeyWalletTabContent({
    super.key,
    required this.tab,
    required this.transactions,
    required this.depositOrders,
    required this.withdrawals,
    required this.onDepositTap,
    required this.onWithdrawalTap,
  });

  final JockeyWalletTab tab;
  final List<WalletTransactionResponse> transactions;
  final List<DepositOrderResponse> depositOrders;
  final List<WithdrawalResponse> withdrawals;
  final ValueChanged<DepositOrderResponse> onDepositTap;
  final ValueChanged<WithdrawalResponse> onWithdrawalTap;

  @override
  Widget build(BuildContext context) {
    return switch (tab) {
      JockeyWalletTab.transactions => _TransactionList(
        transactions: transactions,
      ),
      JockeyWalletTab.deposits => _DepositList(
        orders: depositOrders,
        onTap: onDepositTap,
      ),
      JockeyWalletTab.withdrawals => _WithdrawalList(
        withdrawals: withdrawals,
        onTap: onWithdrawalTap,
      ),
    };
  }
}

class JockeyWalletInfoBanner extends StatelessWidget {
  const JockeyWalletInfoBanner({
    super.key,
    required this.message,
    this.isError = true,
  });

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color = isError
        ? RefereeColors.statusRed
        : RefereeColors.successEmerald;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(message, style: AppTypography.bodySm(color)),
    );
  }
}

class JockeyWalletDetailSheet extends StatelessWidget {
  const JockeyWalletDetailSheet({
    super.key,
    required this.title,
    required this.rows,
  });

  final String title;
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: AppTypography.headlineSm(RefereeColors.onSurface),
            ),
            const SizedBox(height: AppSpacing.lg),
            for (final row in rows)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 120,
                      child: Text(
                        row.$1,
                        style: AppTypography.bodySm(
                          RefereeColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        row.$2,
                        style: AppTypography.bodyMd(RefereeColors.onSurface),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BalanceValue extends StatelessWidget {
  const _BalanceValue({
    required this.label,
    required this.value,
    required this.currency,
  });

  final String label;
  final num value;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.bodySm(RefereeColors.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          Text(
            '${formatVnd(value)} $currency',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodyMd(
              RefereeColors.onSurface,
            ).copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active
        ? RefereeColors.successEmerald
        : RefereeColors.statusRed;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.labelCaps(color).copyWith(fontSize: 10),
      ),
    );
  }
}

class _TransactionList extends StatelessWidget {
  const _TransactionList({required this.transactions});

  final List<WalletTransactionResponse> transactions;

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const JockeyStateMessage(message: 'Chưa có giao dịch nào.');
    }
    return _WalletListCard(
      children: [
        for (final transaction in transactions)
          _WalletRow(
            key: Key('jockey-transaction-${transaction.id}'),
            icon: isWalletCreditDirection(transaction.direction)
                ? Icons.south_west_rounded
                : Icons.north_east_rounded,
            title: walletTransactionTypeLabel(transaction.type),
            subtitle:
                '${walletTransactionDirectionLabel(transaction.direction)} • '
                '${formatDisplayDateTime(transaction.createdAt?.toIso8601String())}',
            amount:
                '${isWalletCreditDirection(transaction.direction) ? '+' : '-'}'
                '${formatVnd(transaction.amount)}',
            status: walletTransactionStatusLabel(transaction.status),
            positive: isWalletCreditDirection(transaction.direction),
          ),
      ],
    );
  }
}

class _DepositList extends StatelessWidget {
  const _DepositList({required this.orders, required this.onTap});

  final List<DepositOrderResponse> orders;
  final ValueChanged<DepositOrderResponse> onTap;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const JockeyStateMessage(message: 'Chưa có lệnh nạp tiền nào.');
    }
    return _WalletListCard(
      children: [
        for (final order in orders)
          _WalletRow(
            key: Key('jockey-deposit-${order.id}'),
            icon: Icons.add_card_outlined,
            title: order.referenceCode ?? 'Lệnh nạp #${order.id}',
            subtitle:
                '${order.provider ?? 'ZALOPAY'} • '
                '${formatDisplayDateTime(order.createdAt?.toIso8601String())}',
            amount: formatVnd(order.amount),
            status: _depositStatusLabel(order.status),
            positive: true,
            onTap: () => onTap(order),
          ),
      ],
    );
  }
}

class _WithdrawalList extends StatelessWidget {
  const _WithdrawalList({required this.withdrawals, required this.onTap});

  final List<WithdrawalResponse> withdrawals;
  final ValueChanged<WithdrawalResponse> onTap;

  @override
  Widget build(BuildContext context) {
    if (withdrawals.isEmpty) {
      return const JockeyStateMessage(message: 'Chưa có yêu cầu rút tiền nào.');
    }
    return _WalletListCard(
      children: [
        for (final withdrawal in withdrawals)
          _WalletRow(
            key: Key('jockey-withdrawal-${withdrawal.id}'),
            icon: Icons.account_balance_outlined,
            title: '${withdrawal.bankName} • ${withdrawal.bankAccountNumber}',
            subtitle:
                '${withdrawal.bankAccountName} • '
                '${formatDisplayDateTime(withdrawal.createdAt?.toIso8601String())}',
            amount: '-${formatVnd(withdrawal.amount)}',
            status: _withdrawalStatusLabel(withdrawal.status),
            positive: false,
            onTap: () => onTap(withdrawal),
          ),
      ],
    );
  }
}

class _WalletListCard extends StatelessWidget {
  const _WalletListCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return RefereeGlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var index = 0; index < children.length; index++) ...[
            children[index],
            if (index < children.length - 1)
              Divider(height: 1, color: Colors.white.withValues(alpha: 0.08)),
          ],
        ],
      ),
    );
  }
}

class _WalletRow extends StatelessWidget {
  const _WalletRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.status,
    required this.positive,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String amount;
  final String status;
  final bool positive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = positive
        ? RefereeColors.successEmerald
        : RefereeColors.onSurface;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Icon(icon, color: RefereeColors.championshipGold),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyMd(
                      RefereeColors.onSurface,
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTypography.bodySm(RefereeColors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  style: AppTypography.bodyMd(
                    color,
                  ).copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  status.toUpperCase(),
                  style: AppTypography.labelCaps(
                    RefereeColors.onSurfaceVariant,
                  ).copyWith(fontSize: 9),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _depositStatusLabel(String? status) {
  return switch (status) {
    'PENDING' => 'Đang chờ',
    'PAID' => 'Đã thanh toán',
    'FAILED' => 'Thất bại',
    'EXPIRED' => 'Hết hạn',
    'CANCELLED' => 'Đã hủy',
    _ => status ?? '—',
  };
}

String _withdrawalStatusLabel(String? status) {
  return switch (status) {
    'PENDING' => 'Đang chờ',
    'APPROVED' => 'Đã duyệt',
    'REJECTED' => 'Bị từ chối',
    'PAID' => 'Đã thanh toán',
    'CANCELLED' => 'Đã hủy',
    _ => status ?? '—',
  };
}
