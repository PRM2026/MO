class RegisterViewModel {
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  void togglePasswordVisibility() => obscurePassword = !obscurePassword;

  void toggleConfirmPasswordVisibility() =>
      obscureConfirmPassword = !obscureConfirmPassword;

  String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập họ và tên';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập email';
    }
    if (!value.trim().contains('@')) return 'Email không hợp lệ';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu';
    if (value.length < 6) return 'Mật khẩu tối thiểu 6 ký tự';
    return null;
  }

  String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng xác nhận mật khẩu';
    }
    if (value != password) return 'Mật khẩu không khớp';
    return null;
  }

  Future<bool> submit({
    required String fullName,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return fullName.isNotEmpty && email.isNotEmpty && password.isNotEmpty;
  }
}
