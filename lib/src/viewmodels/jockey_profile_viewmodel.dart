import 'package:flutter/foundation.dart';

import '../models/referee_profile_data.dart';
import '../repositories/auth_repository.dart';
import '../repositories/jockey_profile_repository.dart';

class JockeyProfileViewModel extends ChangeNotifier {
  JockeyProfileViewModel({
    JockeyProfileRepository? repository,
    AuthRepository? authRepository,
  }) : _repository = repository ?? JockeyProfileRepository(),
       _authRepository = authRepository ?? AuthRepository();

  final JockeyProfileRepository _repository;
  final AuthRepository _authRepository;

  bool isLoading = false;
  bool isLoggingOut = false;
  String? errorMessage;
  RefereeProfileData? data;

  Future<void> loadData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      data = await _repository.fetchProfile();
    } catch (error) {
      if (kDebugMode) debugPrint('JockeyProfileViewModel: $error');
      data = null;
      errorMessage = 'Khong the tai ho so jockey.';
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
      if (kDebugMode) debugPrint('JockeyProfileViewModel logout: $error');
      return false;
    } finally {
      isLoggingOut = false;
      notifyListeners();
    }
  }
}
