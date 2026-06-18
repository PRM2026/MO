import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:horse_racing/src/models/auth_session.dart';
import 'package:horse_racing/src/services/auth_storage.dart';
import 'package:horse_racing/src/services/jockey_race_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('JockeyRaceService schedule APIs', () {
    test(
      'loads jockey races with bearer token and parses full response',
      () async {
        final storage = await _storageWithToken('jockey-token');
        final service = JockeyRaceService(
          baseUrl: 'http://example.test',
          storage: storage,
          client: MockClient((request) async {
            expect(request.method, 'GET');
            expect(request.url.toString(), 'http://example.test/jockey/races');
            expect(request.headers['Accept'], 'application/json');
            expect(request.headers['Authorization'], 'Bearer jockey-token');
            return _jsonResponse({
              'success': true,
              'message': 'Success',
              'data': [_raceJson()],
            });
          }),
        );

        final race = (await service.getJockeyRaces()).single;

        expect(race.id, '22');
        expect(race.tournamentId, '7');
        expect(race.name, 'Autumn Sprint');
        expect(race.distance, '1600m');
        expect(race.venueName, 'Saigon Track');
        expect(race.venueAddress, 'District 7');
        expect(race.provinceName, 'HCMC');
        expect(race.scheduledStartAt, DateTime.parse('2026-06-18T08:00:00'));
        expect(race.scheduledEndAt, DateTime.parse('2026-06-18T09:00:00'));
        expect(race.refereeUsername, 'referee01');
        expect(race.status, 'SCHEDULED');
        expect(race.participantCount, 8);
      },
    );

    test('parses nullable timestamps and string ids', () async {
      final storage = await _storageWithToken('jockey-token');
      final service = JockeyRaceService(
        baseUrl: 'http://example.test',
        storage: storage,
        client: MockClient((_) async {
          return _jsonResponse({
            'success': true,
            'message': 'Success',
            'data': [
              _raceJson(
                id: 'race-raw-id',
                tournamentId: 'tour-raw-id',
                scheduledStartAt: null,
                scheduledEndAt: null,
                participantCount: '3',
              ),
            ],
          });
        }),
      );

      final race = (await service.getJockeyRaces()).single;

      expect(race.id, 'race-raw-id');
      expect(race.tournamentId, 'tour-raw-id');
      expect(race.scheduledStartAt, isNull);
      expect(race.scheduledEndAt, isNull);
      expect(race.participantCount, 3);
    });

    test('wraps success false with backend message', () async {
      final storage = await _storageWithToken('jockey-token');
      final service = JockeyRaceService(
        baseUrl: 'http://example.test',
        storage: storage,
        client: MockClient((_) async {
          return _jsonResponse({
            'success': false,
            'message': 'Không thể tải lịch đua',
            'data': null,
          }, statusCode: 400);
        }),
      );

      expect(
        service.getJockeyRaces,
        throwsA(
          isA<JockeyRaceApiException>().having(
            (error) => error.message,
            'message',
            'Không thể tải lịch đua',
          ),
        ),
      );
    });

    test('wraps validation data when backend message is empty', () async {
      final storage = await _storageWithToken('jockey-token');
      final service = JockeyRaceService(
        baseUrl: 'http://example.test',
        storage: storage,
        client: MockClient((_) async {
          return _jsonResponse({
            'success': false,
            'message': '',
            'data': {
              'status': ['Trạng thái không hợp lệ'],
            },
          }, statusCode: 422);
        }),
      );

      expect(
        service.getJockeyRaces,
        throwsA(
          isA<JockeyRaceApiException>().having(
            (error) => error.message,
            'message',
            'Trạng thái không hợp lệ',
          ),
        ),
      );
    });

    test('wraps non-json response as schedule exception', () async {
      final storage = await _storageWithToken('jockey-token');
      final service = JockeyRaceService(
        baseUrl: 'http://example.test',
        storage: storage,
        client: MockClient((_) async => http.Response('Server down', 500)),
      );

      expect(service.getJockeyRaces, throwsA(isA<JockeyRaceApiException>()));
    });
  });
}

Map<String, dynamic> _raceJson({
  Object? id = 22,
  Object? tournamentId = 7,
  String? scheduledStartAt = '2026-06-18T08:00:00',
  String? scheduledEndAt = '2026-06-18T09:00:00',
  Object? participantCount = 8,
}) {
  return {
    'id': id,
    'tournamentId': tournamentId,
    'name': 'Autumn Sprint',
    'distance': '1600m',
    'venueName': 'Saigon Track',
    'venueAddress': 'District 7',
    'provinceName': 'HCMC',
    'scheduledStartAt': scheduledStartAt,
    'scheduledEndAt': scheduledEndAt,
    'refereeUsername': 'referee01',
    'status': 'SCHEDULED',
    'participantCount': participantCount,
  };
}

http.Response _jsonResponse(Map<String, dynamic> body, {int statusCode = 200}) {
  return http.Response.bytes(
    utf8.encode(jsonEncode(body)),
    statusCode,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
}

Future<AuthStorage> _storageWithToken(String token) async {
  SharedPreferences.setMockInitialValues({});
  final preferences = await SharedPreferences.getInstance();
  final storage = AuthStorage(preferences: preferences);
  await storage.saveSession(
    AuthSession(token: token, tokenType: 'Bearer', role: 'JOCKEY'),
  );
  return storage;
}
