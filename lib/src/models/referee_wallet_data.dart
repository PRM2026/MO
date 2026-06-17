import '../utils/currency_format.dart';
import '../utils/date_format.dart';
import '../utils/wallet_labels.dart';

class WalletBalanceOverview {
  const WalletBalanceOverview({
    required this.availableBalance,
    required this.holdBalance,
    required this.totalBalance,
    required this.currency,
    required this.statusLabel,
  });

  final String availableBalance;
  final String holdBalance;
  final String totalBalance;
  final String currency;
  final String statusLabel;
}

class WalletTransactionItem {
  const WalletTransactionItem({
    required this.id,
    required this.title,
    required this.meta,
    required this.amountLabel,
    required this.isCredit,
    required this.statusLabel,
    this.note,
  });

  final String id;
  final String title;
  final String meta;
  final String amountLabel;
  final bool isCredit;
  final String statusLabel;
  final String? note;
}

class RefereeWalletData {
  const RefereeWalletData({
    required this.balance,
    required this.transactions,
    this.profileImageUrl,
  });

  final WalletBalanceOverview balance;
  final List<WalletTransactionItem> transactions;
  final String? profileImageUrl;

  factory RefereeWalletData.empty({String? profileImageUrl}) {
    return RefereeWalletData(
      profileImageUrl: profileImageUrl,
      balance: const WalletBalanceOverview(
        availableBalance: '0',
        holdBalance: '0',
        totalBalance: '0',
        currency: 'VND',
        statusLabel: '—',
      ),
      transactions: const [],
    );
  }

  factory RefereeWalletData.fromApi({
    required Map<String, dynamic> wallet,
    required List<Map<String, dynamic>> transactions,
    String? profileImageUrl,
  }) {
    final available = _readNum(wallet['availableBalance']);
    final hold = _readNum(wallet['holdBalance']);
    final total = wallet['totalBalance'] != null
        ? _readNum(wallet['totalBalance'])
        : available + hold;

    return RefereeWalletData(
      profileImageUrl: profileImageUrl,
      balance: WalletBalanceOverview(
        availableBalance: formatVnd(available).replaceAll(' đ', ''),
        holdBalance: formatVnd(hold).replaceAll(' đ', ''),
        totalBalance: formatVnd(total).replaceAll(' đ', ''),
        currency: wallet['currency']?.toString() ?? 'VND',
        statusLabel: walletStatusLabel(wallet['status']?.toString()),
      ),
      transactions: transactions.map(_mapTransaction).toList(growable: false),
    );
  }

  static WalletTransactionItem _mapTransaction(Map<String, dynamic> tx) {
    final direction = tx['direction']?.toString();
    final amount = _readNum(tx['amount']);
    final isCredit = isWalletCreditDirection(direction);
    final signedPrefix = isCredit ? '+' : '-';
    final id = tx['id']?.toString() ?? '—';
    final createdAt = formatDisplayDateTime(tx['createdAt']?.toString());
    final note = tx['note']?.toString();
    final referenceType = tx['referenceType']?.toString();
    final description = (note != null && note.trim().isNotEmpty)
        ? note.trim()
        : (referenceType ?? walletTransactionTypeLabel(tx['type']?.toString()));

    return WalletTransactionItem(
      id: id,
      title: walletTransactionTypeLabel(tx['type']?.toString()),
      meta: '$createdAt • ${walletTransactionDirectionLabel(direction)} • #$id',
      amountLabel: '$signedPrefix${formatVnd(amount)}',
      isCredit: isCredit,
      statusLabel: walletTransactionStatusLabel(tx['status']?.toString()),
      note: description != walletTransactionTypeLabel(tx['type']?.toString())
          ? description
          : null,
    );
  }
}

num _readNum(Object? value) {
  if (value is num) return value;
  if (value is String) return num.tryParse(value) ?? 0;
  return 0;
}
