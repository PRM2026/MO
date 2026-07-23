import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:horse_racing/src/services/auth_api_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('login accepts the UUID userId returned by the Railway API', () async {
    final service = AuthApiService(
      baseUrl: 'https://api.example.test',
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({
            'success': true,
            'message': 'Đăng nhập thành công',
            'data': {
              'token': 'jwt-token',
              'tokenType': 'Bearer',
              'userId': '6a45ffa2f39ce4024ca749e9',
              'role': 'OWNER',
            },
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        ),
      ),
    );

    final session = await service.login(
      email: 'owner1@hr.vn',
      password: 'Password123!',
    );

    expect(session.token, 'jwt-token');
    expect(session.role, 'OWNER');
  });

  test(
    'login returns two-factor challenge without requiring a token',
    () async {
      final service = AuthApiService(
        baseUrl: 'https://api.example.test',
        client: MockClient(
          (_) async => http.Response(
            jsonEncode({
              'success': true,
              'message': 'Two-factor authentication required',
              'data': {
                'token': null,
                'twoFactorRequired': true,
                'challengeId': 'challenge-1',
                'email': 'rider@example.test',
                'challengeExpiresAt': '2026-07-23T12:30:00',
              },
            }),
            200,
          ),
        ),
      );

      final session = await service.login(
        email: 'rider@example.test',
        password: 'Race123',
      );

      expect(session.twoFactorRequired, isTrue);
      expect(session.challengeId, 'challenge-1');
      expect(session.token, isEmpty);
      expect(session.challengeExpiresAt, isNotNull);
    },
  );

  test('verify two-factor submits challenge and returns token', () async {
    late http.Request captured;
    final service = AuthApiService(
      baseUrl: 'https://api.example.test',
      client: MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode({
            'success': true,
            'message': 'Two-factor verification successful',
            'data': {
              'token': 'jwt-token',
              'tokenType': 'Bearer',
              'twoFactorRequired': false,
              'role': 'JOCKEY',
            },
          }),
          200,
        );
      }),
    );

    final session = await service.verifyTwoFactor(
      challengeId: 'challenge-1',
      otp: '123456',
    );

    expect(captured.url.path, '/auth/2fa/verify');
    expect(jsonDecode(captured.body), {
      'challengeId': 'challenge-1',
      'otp': '123456',
    });
    expect(session.token, 'jwt-token');
  });
}
