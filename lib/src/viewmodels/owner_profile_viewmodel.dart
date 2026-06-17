import 'package:flutter/foundation.dart';

import '../models/owner_profile_data.dart';
import '../repositories/auth_repository.dart';

class OwnerProfileViewModel extends ChangeNotifier {
  OwnerProfileViewModel({AuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepository();

  final AuthRepository _authRepository;

  bool isLoading = false;
  bool isLoggingOut = false;
  String? errorMessage;
  OwnerProfileData? data;

  Future<void> loadData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final user = await _authRepository.refreshCurrentUser();
      data = OwnerProfileData.fromUserProfile(user);
    } catch (error) {
      data = null;
      errorMessage = 'Không thể tải hồ sơ chủ ngựa.';
      if (kDebugMode) debugPrint('OwnerProfileViewModel: $error');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshData() => loadData();

  Future<bool> logout() async {
    isLoggingOut = true;
    notifyListeners();

    try {
      await _authRepository.logout();
      return true;
    } catch (error) {
      if (kDebugMode) debugPrint('OwnerProfileViewModel logout: $error');
      return false;
    } finally {
      isLoggingOut = false;
      notifyListeners();
    }
  }
}
