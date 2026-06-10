import '../repositories/auth_repository.dart';
import '../services/auth_api_service.dart';

class RegisterViewModel {
  RegisterViewModel({AuthRepository? repository})
      : _repository = repository ?? AuthRepository();

  final AuthRepository _repository;

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  String? errorMessage;

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
    errorMessage = null;
    try {
      await _repository.register(
        fullName: fullName,
        email: email,
        password: password,
      );
      return true;
    } on AuthApiException catch (error) {
      errorMessage = error.message;
      return false;
    } catch (_) {
      errorMessage = 'Không thể đăng ký. Hãy bật BE và thử lại.';
      return false;
    }
  }
}
