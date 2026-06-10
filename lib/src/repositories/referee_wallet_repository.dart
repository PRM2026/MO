import '../models/referee_wallet_data.dart';

class RefereeWalletRepository {
  const RefereeWalletRepository();

  Future<RefereeWalletData> fetchWallet() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return RefereeWalletData.sample();
  }
}
