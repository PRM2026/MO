import 'package:flutter/foundation.dart';

import '../models/referee_wallet_data.dart';
import '../repositories/referee_wallet_repository.dart';

class RefereeWalletViewModel extends ChangeNotifier {
  RefereeWalletViewModel({RefereeWalletRepository? repository})
    : _repository = repository ?? RefereeWalletRepository();

  final RefereeWalletRepository _repository;

  bool isLoading = false;
  RefereeWalletData? data;
  String? errorMessage;

  Future<void> loadData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      data = await _repository.fetchWallet();
    } catch (error) {
      if (kDebugMode) debugPrint('RefereeWalletViewModel: $error');
      errorMessage = 'Không thể tải số dư ví. Vui lòng thử lại.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
