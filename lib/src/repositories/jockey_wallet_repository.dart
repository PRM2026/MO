import '../models/deposit_order_response.dart';
import '../models/jockey_wallet_data.dart';
import '../models/wallet_response.dart';
import '../models/wallet_transaction_response.dart';
import '../models/withdrawal_response.dart';
import '../services/jockey_wallet_service.dart';

class JockeyWalletRepository {
  JockeyWalletRepository({JockeyWalletService? service})
    : _service = service ?? JockeyWalletService();

  final JockeyWalletService _service;

  Future<JockeyWalletData> fetchWallet() async {
    final values = await Future.wait<Object>([
      _service.getWallet(),
      _service.getTransactions(),
      _service.getDepositOrders(),
      _service.getWithdrawals(),
    ]);

    final transactions = List<WalletTransactionResponse>.of(
      values[1] as List<WalletTransactionResponse>,
    )..sort((a, b) => _compareDates(b.createdAt, a.createdAt));
    final depositOrders = List<DepositOrderResponse>.of(
      values[2] as List<DepositOrderResponse>,
    )..sort((a, b) => _compareDates(b.createdAt, a.createdAt));
    final withdrawals = List<WithdrawalResponse>.of(
      values[3] as List<WithdrawalResponse>,
    )..sort((a, b) => _compareDates(b.createdAt, a.createdAt));

    return JockeyWalletData(
      wallet: values[0] as WalletResponse,
      transactions: transactions,
      depositOrders: depositOrders,
      withdrawals: withdrawals,
    );
  }

  Future<DepositOrderResponse> createDepositOrder({required int amount}) {
    return _service.createDepositOrder(amount: amount);
  }

  Future<DepositOrderResponse> getDepositOrder(String id) {
    return _service.getDepositOrder(id);
  }

  Future<WithdrawalResponse> createWithdrawal({
    required num amount,
    required String bankName,
    required String bankAccountNumber,
    required String bankAccountName,
    String? reason,
  }) {
    return _service.createWithdrawal(
      amount: amount,
      bankName: bankName,
      bankAccountNumber: bankAccountNumber,
      bankAccountName: bankAccountName,
      reason: reason,
    );
  }

  Future<WithdrawalResponse> getWithdrawal(String id) {
    return _service.getWithdrawal(id);
  }
}

int _compareDates(DateTime? left, DateTime? right) {
  if (left == null && right == null) return 0;
  if (left == null) return -1;
  if (right == null) return 1;
  return left.compareTo(right);
}
