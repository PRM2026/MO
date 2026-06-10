class LoginViewModel {
  bool rememberMe = false;
  bool obscurePassword = true;

  void toggleRememberMe() => rememberMe = !rememberMe;

  void togglePasswordVisibility() => obscurePassword = !obscurePassword;

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập email';
    }
    final email = value.trim();
    if (!email.contains('@')) return 'Email không hợp lệ';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu';
    if (value.length < 6) return 'Mật khẩu tối thiểu 6 ký tự';
    return null;
  }

  Future<bool> submit({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return email.isNotEmpty && password.isNotEmpty;
  }
}
