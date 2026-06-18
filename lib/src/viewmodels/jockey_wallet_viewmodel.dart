import 'package:flutter/foundation.dart';

import '../models/deposit_order_response.dart';
import '../models/jockey_wallet_data.dart';
import '../models/withdrawal_response.dart';
import '../repositories/jockey_wallet_repository.dart';
import '../services/api_exception.dart';

enum JockeyWalletTab { transactions, deposits, withdrawals }

class JockeyWalletViewModel extends ChangeNotifier {
  JockeyWalletViewModel({JockeyWalletRepository? repository})
    : _repository = repository ?? JockeyWalletRepository();

  final JockeyWalletRepository _repository;

  bool isLoading = false;
  bool isLoadingDetail = false;
  String? errorMessage;
  String? detailError;
  JockeyWalletData? data;
  JockeyWalletTab selectedTab = JockeyWalletTab.transactions;

  void selectTab(JockeyWalletTab tab) {
    if (selectedTab == tab) return;
    selectedTab = tab;
    notifyListeners();
  }

  Future<void> loadWallet() async {
    if (isLoading) return;
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      data = await _repository.fetchWallet();
    } on ApiException catch (error) {
      errorMessage = error.message;
    } catch (error) {
      if (kDebugMode) debugPrint('JockeyWalletViewModel: $error');
      errorMessage = 'Không thể tải thông tin ví. Vui lòng thử lại.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<DepositOrderResponse?> loadDepositDetail(String id) async {
    return _loadDetail(() => _repository.getDepositOrder(id));
  }

  Future<WithdrawalResponse?> loadWithdrawalDetail(String id) async {
    return _loadDetail(() => _repository.getWithdrawal(id));
  }

  Future<T?> _loadDetail<T>(Future<T> Function() request) async {
    if (isLoadingDetail) return null;
    isLoadingDetail = true;
    detailError = null;
    notifyListeners();
    try {
      return await request();
    } on ApiException catch (error) {
      detailError = error.message;
      return null;
    } catch (error) {
      if (kDebugMode) debugPrint('JockeyWalletViewModel detail: $error');
      detailError = 'Không thể tải chi tiết. Vui lòng thử lại.';
      return null;
    } finally {
      isLoadingDetail = false;
      notifyListeners();
    }
  }
}
