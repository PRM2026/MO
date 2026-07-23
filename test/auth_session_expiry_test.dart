import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:horse_racing/src/models/auth_session.dart';
import 'package:horse_racing/src/repositories/auth_repository.dart';
import 'package:horse_racing/src/services/auth_api_service.dart';
import 'package:horse_racing/src/services/auth_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'expired server session is cleared instead of restoring cached role',
    () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final storage = AuthStorage(preferences: preferences);
      await storage.saveSession(
        const AuthSession(
          token: 'expired-token',
          tokenType: 'Bearer',
          role: 'JOCKEY',
        ),
      );

      final apiService = AuthApiService(
        baseUrl: 'http://example.test',
        client: MockClient((request) async {
          expect(request.url.toString(), 'http://example.test/auth/me');
          expect(request.headers['Authorization'], 'Bearer expired-token');
          return http.Response.bytes(
            utf8.encode(
              '{"success":false,"message":"Unauthorized","data":null}',
            ),
            401,
          );
        }),
      );
      final repository = AuthRepository(
        apiService: apiService,
        storage: storage,
      );

      expect(await repository.resolveNavigationRole(), 'USER');
      expect(await repository.isLoggedIn(), isFalse);
      expect((await repository.loadProfile()).role, isNull);
    },
  );
}
