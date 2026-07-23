import '../models/auth_session.dart';
import '../models/stored_auth_profile.dart';
import '../models/user_profile.dart';
import '../services/auth_api_service.dart';
import '../services/auth_storage.dart';
import '../utils/username_utils.dart';

class AuthRepository {
  AuthRepository({AuthApiService? apiService, AuthStorage? storage})
    : _apiService = apiService ?? AuthApiService(),
      _storage = storage ?? AuthStorage();

  final AuthApiService _apiService;
  final AuthStorage _storage;

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final session = await _apiService.login(email: email, password: password);
    if (session.twoFactorRequired) return session;
    await _saveAuthenticatedSession(session);
    return session;
  }

  Future<AuthSession> verifyTwoFactor({
    required String challengeId,
    required String otp,
  }) async {
    final session = await _apiService.verifyTwoFactor(
      challengeId: challengeId,
      otp: otp,
    );
    await _saveAuthenticatedSession(session);
    return session;
  }

  Future<AuthSession> resendTwoFactor({required String challengeId}) {
    return _apiService.resendTwoFactor(challengeId: challengeId);
  }

  Future<void> _saveAuthenticatedSession(AuthSession session) async {
    await _storage.saveSession(session);
    await _syncRoleFields(
      role: session.role,
      pendingRole: session.pendingRole,
      roleApprovalStatus: session.roleApprovalStatus,
    );
  }

  Future<AuthSession> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final session = await _apiService.register(
      username: UsernameUtils.deriveFromEmail(email),
      fullName: fullName,
      email: email,
      password: password,
    );
    await _storage.saveSession(session);
    await _syncRoleFields(
      role: session.role,
      pendingRole: session.pendingRole,
      roleApprovalStatus: session.roleApprovalStatus,
    );
    return session;
  }

  Future<void> logout() => _storage.clearSession();

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final token = await _storage.getToken();
    if (token == null || token.isEmpty) {
      throw AuthApiException(
        'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
      );
    }

    await _apiService.changePassword(
      token: token,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  Future<bool> isLoggedIn() => _storage.isLoggedIn();

  Future<StoredAuthProfile> loadProfile() => _storage.loadProfile();

  Future<UserProfile> refreshCurrentUser() async {
    final token = await _storage.getToken();
    if (token == null || token.isEmpty) {
      throw AuthApiException(
        'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
      );
    }

    final user = await _apiService.getMe(token: token);
    await _syncRoleFields(
      role: user.role,
      pendingRole: user.pendingRole,
      roleApprovalStatus: user.roleApprovalStatus,
    );
    if (user.fullName != null && user.fullName!.isNotEmpty) {
      await _storage.updateFullName(user.fullName!);
    }
    return user;
  }

  Future<void> _syncRoleFields({
    required String? role,
    required String? pendingRole,
    required String? roleApprovalStatus,
  }) async {
    await _storage.updateRole(_normalizeRole(role));
    await _storage.updatePendingRole(pendingRole);
    await _storage.updateRoleApprovalStatus(roleApprovalStatus);
  }

  /// Role used for portal navigation — always refreshed from server when possible.
  Future<String> resolveNavigationRole() async {
    try {
      final user = await refreshCurrentUser();
      return user.effectiveAppRole;
    } catch (_) {
      return (await loadProfile()).effectiveAppRole;
    }
  }

  static String _normalizeRole(String? role) {
    return (role ?? 'USER').trim().toUpperCase();
  }
}
