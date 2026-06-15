import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:horse_racing/src/models/auth_session.dart';
import 'package:horse_racing/src/services/auth_storage.dart';
import 'package:horse_racing/src/services/owner_horse_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'calls owner horses API with bearer token and maps HorseResponse',
    () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final storage = AuthStorage(preferences: preferences);
      await storage.saveSession(
        const AuthSession(
          token: 'owner-token',
          tokenType: 'Bearer',
          role: 'OWNER',
        ),
      );

      final client = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.toString(), 'http://example.test/owner/horses');
        expect(request.headers['Authorization'], 'Bearer owner-token');
        return http.Response.bytes(
          utf8.encode('''
          {
            "success": true,
            "message": "Success",
            "data": [
              {
                "id": 7,
                "name": "Bão Đêm",
                "breed": "Thoroughbred",
                "age": 4,
                "gender": "Đực",
                "color": "Đen",
                "heightCm": 165.5,
                "weightKg": 480,
                "imageUrl": "/uploads/horses/7.jpg",
                "status": "APPROVED",
                "performance": {
                  "totalRaces": 5,
                  "wins": 2,
                  "winRate": 40
                }
              }
            ]
          }
          '''),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });
      final service = OwnerHorseService(
        client: client,
        baseUrl: 'http://example.test',
        storage: storage,
      );

      final horses = await service.getOwnerHorses();

      expect(horses, hasLength(1));
      expect(horses.single.id, '7');
      expect(horses.single.name, 'Bão Đêm');
      expect(horses.single.statusCode, 'APPROVED');
      expect(horses.single.heightCm, 165.5);
      expect(horses.single.weightKg, 480);
      expect(horses.single.performance.totalRaces, 5);
      expect(horses.single.performance.wins, 2);
      expect(horses.single.performance.winRate, 40);
    },
  );

  test('requires a saved login token', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final service = OwnerHorseService(
      client: MockClient((_) async => http.Response('{}', 200)),
      baseUrl: 'http://example.test',
      storage: AuthStorage(preferences: preferences),
    );

    expect(service.getOwnerHorses, throwsA(isA<OwnerApiException>()));
  });
}
