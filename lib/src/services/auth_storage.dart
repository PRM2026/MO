import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_session.dart';
import '../models/stored_auth_profile.dart';

class AuthStorage {
  AuthStorage({SharedPreferences? preferences})
      : _preferences = preferences;

  SharedPreferences? _preferences;

  static const _tokenKey = 'auth_token';
  static const _tokenTypeKey = 'auth_token_type';
  static const _userIdKey = 'auth_user_id';
  static const _emailKey = 'auth_email';
  static const _fullNameKey = 'auth_full_name';
  static const _roleKey = 'auth_role';

  Future<SharedPreferences> get _prefs async {
    return _preferences ??= await SharedPreferences.getInstance();
  }

  Future<void> saveSession(AuthSession session) async {
    final prefs = await _prefs;
    await prefs.setString(_tokenKey, session.token);
    await prefs.setString(_tokenTypeKey, session.tokenType);
    if (session.userId != null) {
      await prefs.setInt(_userIdKey, session.userId!);
    }
    if (session.email != null) {
      await prefs.setString(_emailKey, session.email!);
    }
    if (session.fullName != null) {
      await prefs.setString(_fullNameKey, session.fullName!);
    }
    if (session.role != null) {
      await prefs.setString(_roleKey, session.role!);
    }
  }

  Future<void> clearSession() async {
    final prefs = await _prefs;
    await prefs.remove(_tokenKey);
    await prefs.remove(_tokenTypeKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_fullNameKey);
    await prefs.remove(_roleKey);
  }

  Future<String?> getToken() async {
    final prefs = await _prefs;
    return prefs.getString(_tokenKey);
  }

  Future<String?> getFullName() async {
    final prefs = await _prefs;
    return prefs.getString(_fullNameKey);
  }

  Future<StoredAuthProfile> loadProfile() async {
    final prefs = await _prefs;
    return StoredAuthProfile(
      token: prefs.getString(_tokenKey),
      tokenType: prefs.getString(_tokenTypeKey),
      email: prefs.getString(_emailKey),
      fullName: prefs.getString(_fullNameKey),
      role: prefs.getString(_roleKey),
    );
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
