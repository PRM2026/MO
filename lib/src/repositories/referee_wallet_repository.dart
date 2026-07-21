import '../models/referee_wallet_data.dart';
import '../repositories/auth_repository.dart';
import '../services/referee_wallet_service.dart';

class RefereeWalletRepository {
  RefereeWalletRepository({
    RefereeWalletService? walletService,
    AuthRepository? authRepository,
  }) : _walletService = walletService ?? RefereeWalletService(),
       _authRepository = authRepository ?? AuthRepository();

  final RefereeWalletService _walletService;
  final AuthRepository _authRepository;

  Future<RefereeWalletData> fetchWallet() async {
    final profileImageUrl = await _loadProfileImageUrl();
    final wallet = await _walletService.getWallet();

    return RefereeWalletData.fromApi(
      wallet: wallet,
      transactions: const [],
      profileImageUrl: profileImageUrl,
    );
  }

  Future<String?> _loadProfileImageUrl() async {
    try {
      final user = await _authRepository.refreshCurrentUser();
      final avatar = user.avatarUrl?.trim();
      return avatar == null || avatar.isEmpty ? null : avatar;
    } catch (_) {
      return null;
    }
  }
}
