import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../constants/referee_colors.dart';
import '../models/referee_profile_data.dart';
import '../repositories/auth_repository.dart';

class OwnerProfileViewModel extends ChangeNotifier {
  OwnerProfileViewModel({AuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepository();

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
      final user = await _authRepository.refreshCurrentUser();
      final fullName = user.fullName?.trim().isNotEmpty == true
          ? user.fullName!.trim()
          : (user.username ?? 'Chủ ngựa');

      data = RefereeProfileData(
        fullName: fullName,
        refereeId: 'OWN-${user.id ?? 0}',
        rankLabel: 'Chủ ngựa',
        avatarUrl: user.avatarUrl,
        stats: const [],
        settings: const [
          RefereeProfileSettingItem(
            title: 'Bảo mật & Mật khẩu',
            icon: Icons.security_outlined,
            iconColor: RefereeColors.secondary,
          ),
        ],
      );
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
