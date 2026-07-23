import 'package:flutter/foundation.dart';

import '../models/stored_auth_profile.dart';
import '../repositories/auth_repository.dart';

class PersonalInfoViewModel extends ChangeNotifier {
  PersonalInfoViewModel({AuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepository();

  final AuthRepository _authRepository;

  bool isLoading = false;
  bool isLoggingOut = false;
  bool isLoggedIn = false;
  StoredAuthProfile? profile;

  String get displayName {
    final name = profile?.fullName?.trim();
    if (name != null && name.isNotEmpty) return name;
    return 'Khách';
  }

  String get roleLabel {
    if (profile?.isRolePending == true &&
        profile!.normalizedPendingRole.isNotEmpty) {
      return 'Người dùng · Chờ duyệt ${_translateRole(profile!.pendingRole!)}';
    }

    final role = profile?.effectiveAppRole;
    if (role == null || role.isEmpty || role == 'USER') return 'Chưa có';
    return _translateRole(role);
  }

  String? get normalizedRole => profile?.effectiveAppRole;

  bool get isBasicUser {
    final role = normalizedRole;
    return role == null || role == 'USER';
  }

  bool get canAccessJockeyPortal => normalizedRole == 'JOCKEY';

  bool get canAccessRefereePortal => normalizedRole == 'REFEREE';

  Future<void> loadData() async {
    isLoading = true;
    notifyListeners();

    try {
      isLoggedIn = await _authRepository.isLoggedIn();
      if (isLoggedIn) {
        await _authRepository.refreshCurrentUser();
      }
      profile = await _authRepository.loadProfile();
    } catch (error) {
      if (kDebugMode) debugPrint('PersonalInfoViewModel: $error');
      isLoggedIn = false;
      profile = const StoredAuthProfile();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> logout() async {
    isLoggingOut = true;
    notifyListeners();

    try {
      await _authRepository.logout();
      isLoggedIn = false;
      profile = const StoredAuthProfile();
      return true;
    } catch (error) {
      if (kDebugMode) debugPrint('PersonalInfoViewModel logout: $error');
      return false;
    } finally {
      isLoggingOut = false;
      notifyListeners();
    }
  }

  String _translateRole(String role) {
    return switch (role.toUpperCase()) {
      'USER' => 'Người dùng',
      'SPECTATOR' => 'Khán giả',
      'OWNER' => 'Chủ ngựa',
      'JOCKEY' => 'Nài ngựa',
      'REFEREE' => 'Trọng tài',
      'ADMIN' => 'Quản trị viên',
      _ => role,
    };
  }
}
