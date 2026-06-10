import '../repositories/auth_repository.dart';
import '../services/auth_api_service.dart';

class LoginViewModel {
  LoginViewModel({AuthRepository? repository})
      : _repository = repository ?? AuthRepository();

  final AuthRepository _repository;

  bool rememberMe = false;
  bool obscurePassword = true;
  String? errorMessage;

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
    errorMessage = null;
    try {
      await _repository.login(
        email: email,
        password: password,
      );
      return true;
    } on AuthApiException catch (error) {
      errorMessage = error.message;
      return false;
    } catch (_) {
      errorMessage = 'Không thể đăng nhập. Hãy bật BE và thử lại.';
      return false;
    }
  }
}
