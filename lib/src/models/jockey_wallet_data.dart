import 'deposit_order_response.dart';
import 'wallet_response.dart';
import 'wallet_transaction_response.dart';
import 'withdrawal_response.dart';

class JockeyWalletData {
  const JockeyWalletData({
    required this.wallet,
    required this.transactions,
    required this.depositOrders,
    required this.withdrawals,
  });

  final WalletResponse wallet;
  final List<WalletTransactionResponse> transactions;
  final List<DepositOrderResponse> depositOrders;
  final List<WithdrawalResponse> withdrawals;
}
