import 'package:flutter/foundation.dart';

import '../models/deposit_order_response.dart';
import '../repositories/jockey_wallet_repository.dart';
import '../services/api_exception.dart';

class JockeyDepositViewModel extends ChangeNotifier {
  JockeyDepositViewModel({JockeyWalletRepository? repository})
    : _repository = repository ?? JockeyWalletRepository();

  final JockeyWalletRepository _repository;

  bool isSubmitting = false;
  String? errorMessage;
  DepositOrderResponse? result;

  String? validateAmount(String rawAmount) {
    final value = rawAmount.trim();
    if (value.isEmpty) return 'Vui lòng nhập số tiền.';
    final amount = int.tryParse(value);
    if (amount == null) return 'Số tiền phải là số nguyên VND.';
    if (amount <= 0) return 'Số tiền phải lớn hơn 0.';
    return null;
  }

  void clearError() {
    if (errorMessage == null) return;
    errorMessage = null;
    notifyListeners();
  }

  Future<DepositOrderResponse?> submit(String rawAmount) async {
    if (isSubmitting) return null;
    final validationError = validateAmount(rawAmount);
    if (validationError != null) {
      errorMessage = validationError;
      notifyListeners();
      return null;
    }

    isSubmitting = true;
    errorMessage = null;
    notifyListeners();
    try {
      result = await _repository.createDepositOrder(
        amount: int.parse(rawAmount.trim()),
      );
      return result;
    } on ApiException catch (error) {
      errorMessage = error.message;
      return null;
    } catch (error) {
      if (kDebugMode) debugPrint('JockeyDepositViewModel: $error');
      errorMessage = 'Không thể tạo lệnh nạp tiền.';
      return null;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }
}
