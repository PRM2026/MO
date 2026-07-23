import '../repositories/auth_repository.dart';
import '../models/auth_session.dart';
import '../services/auth_api_service.dart';

class LoginViewModel {
  LoginViewModel({AuthRepository? repository})
    : _repository = repository ?? AuthRepository();

  final AuthRepository _repository;

  bool rememberMe = false;
  bool obscurePassword = true;
  String? errorMessage;
  AuthSession? pendingTwoFactor;

  bool get requiresTwoFactor => pendingTwoFactor != null;
  String? get challengeId => pendingTwoFactor?.challengeId;
  String? get maskedEmail {
    final email = pendingTwoFactor?.email?.trim() ?? '';
    final separator = email.indexOf('@');
    if (separator <= 1) return email;
    return '${email.substring(0, 2)}***${email.substring(separator)}';
  }

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

  Future<bool> submit({required String email, required String password}) async {
    errorMessage = null;
    try {
      final session = await _repository.login(email: email, password: password);
      if (session.twoFactorRequired) {
        pendingTwoFactor = session;
        return false;
      }
      return true;
    } on AuthApiException catch (error) {
      errorMessage = error.message;
      return false;
    } catch (_) {
      errorMessage = 'Không thể đăng nhập. Hãy bật BE và thử lại.';
      return false;
    }
  }

  String? validateOtp(String? value) {
    if (!RegExp(r'^\d{6}$').hasMatch(value?.trim() ?? '')) {
      return 'Mã xác thực phải gồm 6 chữ số';
    }
    return null;
  }

  Future<bool> verifyTwoFactor(String otp) async {
    errorMessage = null;
    final id = challengeId;
    if (id == null || id.isEmpty) {
      errorMessage = 'Phiên xác thực không hợp lệ. Vui lòng đăng nhập lại.';
      return false;
    }
    try {
      await _repository.verifyTwoFactor(challengeId: id, otp: otp);
      pendingTwoFactor = null;
      return true;
    } on AuthApiException catch (error) {
      errorMessage = error.message;
      return false;
    } catch (_) {
      errorMessage = 'Không thể xác thực. Vui lòng thử lại.';
      return false;
    }
  }

  Future<bool> resendTwoFactor() async {
    errorMessage = null;
    final id = challengeId;
    if (id == null || id.isEmpty) return false;
    try {
      pendingTwoFactor = await _repository.resendTwoFactor(challengeId: id);
      return true;
    } on AuthApiException catch (error) {
      errorMessage = error.message;
      return false;
    } catch (_) {
      errorMessage = 'Không thể gửi lại mã xác thực.';
      return false;
    }
  }

  void cancelTwoFactor() {
    pendingTwoFactor = null;
    errorMessage = null;
  }
}
