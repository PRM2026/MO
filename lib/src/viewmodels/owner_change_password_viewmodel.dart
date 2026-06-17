import 'package:flutter/foundation.dart';

import '../repositories/auth_repository.dart';
import '../utils/password_strength.dart';

class OwnerChangePasswordViewModel extends ChangeNotifier {
  OwnerChangePasswordViewModel({AuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepository();

  final AuthRepository _authRepository;

  bool isSubmitting = false;
  String? errorMessage;
  PasswordStrength newPasswordStrength = PasswordStrength.weak;

  void updateNewPasswordStrength(String password) {
    newPasswordStrength = PasswordStrengthUtils.evaluate(password);
    notifyListeners();
  }

  String? validate({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) {
    if (currentPassword.trim().isEmpty) {
      return 'Vui lòng nhập mật khẩu hiện tại.';
    }
    if (!PasswordStrengthUtils.meetsRequirements(newPassword)) {
      return 'Mật khẩu mới chưa đáp ứng yêu cầu bảo mật.';
    }
    if (newPassword != confirmPassword) {
      return 'Xác nhận mật khẩu không khớp.';
    }
    if (currentPassword == newPassword) {
      return 'Mật khẩu mới phải khác mật khẩu hiện tại.';
    }
    return null;
  }

  Future<bool> submit({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    errorMessage = validate(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
    if (errorMessage != null) {
      notifyListeners();
      return false;
    }

    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return true;
    } catch (error) {
      errorMessage = error.toString().replaceFirst('AuthApiException: ', '');
      if (kDebugMode) debugPrint('OwnerChangePasswordViewModel: $error');
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }
}
