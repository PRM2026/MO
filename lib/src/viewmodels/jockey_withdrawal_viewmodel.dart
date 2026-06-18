import 'package:flutter/foundation.dart';

import '../models/withdrawal_response.dart';
import '../repositories/jockey_wallet_repository.dart';
import '../services/api_exception.dart';

class JockeyWithdrawalInput {
  const JockeyWithdrawalInput({
    required this.amount,
    required this.bankName,
    required this.bankAccountNumber,
    required this.bankAccountName,
    required this.reason,
  });

  final String amount;
  final String bankName;
  final String bankAccountNumber;
  final String bankAccountName;
  final String reason;
}

class JockeyWithdrawalViewModel extends ChangeNotifier {
  JockeyWithdrawalViewModel({JockeyWalletRepository? repository})
    : _repository = repository ?? JockeyWalletRepository();

  final JockeyWalletRepository _repository;

  bool isSubmitting = false;
  String? errorMessage;
  WithdrawalResponse? result;

  String? validate(JockeyWithdrawalInput input) {
    final amount = num.tryParse(input.amount.trim());
    if (input.amount.trim().isEmpty) return 'Vui lòng nhập số tiền.';
    if (amount == null || amount <= 0) return 'Số tiền phải lớn hơn 0.';
    if (input.bankName.trim().isEmpty) return 'Vui lòng nhập tên ngân hàng.';
    if (input.bankAccountNumber.trim().isEmpty) {
      return 'Vui lòng nhập số tài khoản.';
    }
    if (input.bankAccountName.trim().isEmpty) {
      return 'Vui lòng nhập tên chủ tài khoản.';
    }
    return null;
  }

  void clearError() {
    if (errorMessage == null) return;
    errorMessage = null;
    notifyListeners();
  }

  Future<WithdrawalResponse?> submit(JockeyWithdrawalInput input) async {
    if (isSubmitting) return null;
    final validationError = validate(input);
    if (validationError != null) {
      errorMessage = validationError;
      notifyListeners();
      return null;
    }

    isSubmitting = true;
    errorMessage = null;
    notifyListeners();
    try {
      result = await _repository.createWithdrawal(
        amount: num.parse(input.amount.trim()),
        bankName: input.bankName.trim(),
        bankAccountNumber: input.bankAccountNumber.trim(),
        bankAccountName: input.bankAccountName.trim(),
        reason: input.reason.trim().isEmpty ? null : input.reason.trim(),
      );
      return result;
    } on ApiException catch (error) {
      errorMessage = error.message;
      return null;
    } catch (error) {
      if (kDebugMode) debugPrint('JockeyWithdrawalViewModel: $error');
      errorMessage = 'Không thể tạo yêu cầu rút tiền.';
      return null;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }
}
