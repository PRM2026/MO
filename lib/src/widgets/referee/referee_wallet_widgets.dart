import 'package:flutter/material.dart';

import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../models/referee_wallet_data.dart';
import 'referee_glass_card.dart';

class RefereeWalletBalanceCard extends StatelessWidget {
  const RefereeWalletBalanceCard({super.key, required this.balance});

  final WalletBalanceOverview balance;

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
                    'Số dư hiện tại',
                    style: AppTypography.labelCaps(
                      RefereeColors.onSurfaceVariant,
                    ).copyWith(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      style: AppTypography.displayLg(RefereeColors.tertiary),
                      children: [
                        TextSpan(text: balance.availableBalance),
                        TextSpan(
                          text: ' ${balance.currency}',
                          style: AppTypography.headlineSm(
                            RefereeColors.tertiary,
                          ).copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
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

class RefereeWalletInfoBanner extends StatelessWidget {
  const RefereeWalletInfoBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: RefereeColors.statusRed.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: RefereeColors.statusRed.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: RefereeColors.statusRed,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTypography.labelCaps(RefereeColors.statusRed).copyWith(
                fontWeight: FontWeight.w400,
                height: 1.5,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
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
              style: AppTypography.headlineSm(
                RefereeColors.onSurface,
              ).copyWith(fontSize: 22),
            ),
          ],
        ),
        const SizedBox(height: 16),
        RefereeGlassCard(
          padding: EdgeInsets.zero,
          child: transactions.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 40,
                    horizontal: 24,
                  ),
                  child: Center(
                    child: Text(
                      'Chưa có giao dịch nào',
                      style: AppTypography.labelCaps(
                        RefereeColors.onSurfaceVariant,
                      ).copyWith(fontWeight: FontWeight.w400),
                    ),
                  ),
                )
              : Column(
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
    final amountColor = item.isCredit
        ? RefereeColors.tertiary
        : RefereeColors.onSurface;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color:
                  (item.isCredit
                          ? RefereeColors.tertiary
                          : RefereeColors.onSurfaceVariant)
                      .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              item.isCredit
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: amountColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: AppTypography.bodyMd(
                    RefereeColors.onSurface,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
                if (item.note != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.note!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelCaps(
                      RefereeColors.onSurfaceVariant,
                    ).copyWith(fontWeight: FontWeight.w400, height: 1.3),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  item.meta,
                  style: AppTypography.labelCaps(
                    RefereeColors.onSurfaceVariant,
                  ).copyWith(fontWeight: FontWeight.w400, fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.amountLabel,
                style: AppTypography.bodySm(
                  amountColor,
                ).copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                item.statusLabel.toUpperCase(),
                style: AppTypography.labelCaps(
                  RefereeColors.onSurfaceVariant,
                ).copyWith(fontSize: 9),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
