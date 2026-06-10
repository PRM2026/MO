import 'package:flutter/foundation.dart';

import '../models/referee_wallet_data.dart';
import '../repositories/referee_wallet_repository.dart';

class RefereeWalletViewModel extends ChangeNotifier {
  RefereeWalletViewModel({RefereeWalletRepository? repository})
      : _repository = repository ?? const RefereeWalletRepository();

  final RefereeWalletRepository _repository;

  bool isLoading = false;
  bool isApproving = false;
  RefereeWalletData? data;

  Future<void> loadData() async {
    isLoading = true;
    notifyListeners();

    try {
      data = await _repository.fetchWallet();
    } catch (error) {
      if (kDebugMode) debugPrint('RefereeWalletViewModel: $error');
      data = RefereeWalletData.sample();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> approveAllDisbursements() async {
    isApproving = true;
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 500));

    isApproving = false;
    notifyListeners();
    return true;
  }
}
