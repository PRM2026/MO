import 'package:flutter/foundation.dart';

import '../services/auth_api_service.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  ForgotPasswordViewModel({AuthApiService? service})
    : _service = service ?? AuthApiService();

  final AuthApiService _service;

  bool isSubmitting = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  String? errorMessage;

  String? validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Vui lòng nhập email';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  String? validateOtp(String? value) {
    final otp = value?.trim() ?? '';
    if (!RegExp(r'^\d{6}$').hasMatch(otp)) {
      return 'Mã OTP phải gồm đúng 6 chữ số';
    }
    return null;
  }

  String? validatePassword(String? value) {
    final password = value ?? '';
    if (password.length < 6) return 'Mật khẩu tối thiểu 6 ký tự';
    if (!password.contains(RegExp(r'[A-Za-z]')) ||
        !password.contains(RegExp(r'\d'))) {
      return 'Mật khẩu cần có cả chữ và số';
    }
    return null;
  }

  String? validateConfirmation(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng xác nhận mật khẩu';
    }
    if (value != password) return 'Mật khẩu xác nhận không khớp';
    return null;
  }

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword = !obscureConfirmPassword;
    notifyListeners();
  }

  Future<bool> sendOtp(String email) async {
    return _run(() => _service.forgotPassword(email: email));
  }

  Future<bool> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    return _run(
      () => _service.resetPassword(
        email: email,
        otp: otp,
        newPassword: newPassword,
      ),
    );
  }

  Future<bool> _run(Future<void> Function() action) async {
    if (isSubmitting) return false;
    isSubmitting = true;
    errorMessage = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on AuthApiException catch (error) {
      errorMessage = error.message;
      return false;
    } catch (_) {
      errorMessage = 'Không thể kết nối máy chủ. Vui lòng thử lại.';
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }
}
