import '../models/auth_session.dart';
import '../models/stored_auth_profile.dart';
import '../services/auth_api_service.dart';
import '../services/auth_storage.dart';
import '../utils/username_utils.dart';

class AuthRepository {
  AuthRepository({
    AuthApiService? apiService,
    AuthStorage? storage,
  })  : _apiService = apiService ?? AuthApiService(),
        _storage = storage ?? AuthStorage();

  final AuthApiService _apiService;
  final AuthStorage _storage;

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final session = await _apiService.login(
      email: email,
      password: password,
    );
    await _storage.saveSession(session);
    return session;
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
    return session;
  }

  Future<void> logout() => _storage.clearSession();

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final token = await _storage.getToken();
    if (token == null || token.isEmpty) {
      throw AuthApiException('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
    }

    await _apiService.changePassword(
      token: token,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  Future<bool> isLoggedIn() => _storage.isLoggedIn();

  Future<StoredAuthProfile> loadProfile() => _storage.loadProfile();
}
