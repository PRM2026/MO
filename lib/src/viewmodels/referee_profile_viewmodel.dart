import 'package:flutter/foundation.dart';

import '../models/referee_profile_data.dart';
import '../repositories/auth_repository.dart';
import '../repositories/referee_profile_repository.dart';

class RefereeProfileViewModel extends ChangeNotifier {
  RefereeProfileViewModel({
    RefereeProfileRepository? repository,
    AuthRepository? authRepository,
  }) : _repository = repository ?? RefereeProfileRepository(),
       _authRepository = authRepository ?? AuthRepository();

  final RefereeProfileRepository _repository;
  final AuthRepository _authRepository;

  bool isLoading = false;
  bool isLoggingOut = false;
  RefereeProfileData? data;
  String? errorMessage;

  Future<void> loadData() async {
    isLoading = true;
    notifyListeners();

    try {
      errorMessage = null;
      data = await _repository.fetchProfile();
    } catch (error) {
      if (kDebugMode) debugPrint('RefereeProfileViewModel: $error');
      errorMessage = 'Không thể tải hồ sơ trọng tài.';
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
      return true;
    } catch (error) {
      if (kDebugMode) debugPrint('RefereeProfileViewModel logout: $error');
      return false;
    } finally {
      isLoggingOut = false;
      notifyListeners();
    }
  }
}
