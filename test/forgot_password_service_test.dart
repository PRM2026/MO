import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:horse_racing/src/services/auth_api_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('forgot password sends the email payload to backend', () async {
    late http.Request captured;
    final service = AuthApiService(
      baseUrl: 'https://api.example.test/api',
      client: MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode({'success': true, 'message': 'OTP sent to email'}),
          200,
        );
      }),
    );

    await service.forgotPassword(email: '  rider@example.test ');

    expect(captured.url.path, '/api/auth/forgot-password');
    expect(jsonDecode(captured.body), {'email': 'rider@example.test'});
  });

  test('reset password sends email, otp and new password', () async {
    late http.Request captured;
    final service = AuthApiService(
      baseUrl: 'https://api.example.test/api',
      client: MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode({'success': true, 'message': 'Password reset successful'}),
          200,
        );
      }),
    );

    await service.resetPassword(
      email: 'rider@example.test',
      otp: ' 123456 ',
      newPassword: 'Race123',
    );

    expect(captured.url.path, '/api/auth/reset-password');
    expect(jsonDecode(captured.body), {
      'email': 'rider@example.test',
      'otp': '123456',
      'newPassword': 'Race123',
    });
  });

  test('reset password exposes backend error message', () async {
    final service = AuthApiService(
      baseUrl: 'https://api.example.test',
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({'success': false, 'message': 'Invalid or expired OTP'}),
          400,
        ),
      ),
    );

    expect(
      () => service.resetPassword(
        email: 'rider@example.test',
        otp: '000000',
        newPassword: 'Race123',
      ),
      throwsA(
        isA<AuthApiException>().having(
          (error) => error.message,
          'message',
          'Invalid or expired OTP',
        ),
      ),
    );
  });
}
