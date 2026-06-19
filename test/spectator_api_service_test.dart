import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:horse_racing/src/models/auth_session.dart';
import 'package:horse_racing/src/services/auth_storage.dart';
import 'package:horse_racing/src/services/spectator_api_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SpectatorApiService', () {
    test('gets public tournaments without bearer token', () async {
      final service = SpectatorApiService(
        baseUrl: 'http://example.test',
        client: MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.toString(), 'http://example.test/tournaments');
          expect(request.headers['Accept'], 'application/json');
          expect(request.headers.containsKey('Authorization'), isFalse);

          return _jsonResponse('''
          {
            "success": true,
            "message": "Success",
            "data": [
              {
                "id": 12,
                "name": "Summer Cup",
                "location": "",
                "provinceName": "Phu Tho",
                "bannerUrl": "/uploads/tournaments/12.jpg",
                "registrationOpenAt": "2026-06-01T08:00:00",
                "startAt": "2026-07-15T09:00:00",
                "endAt": "2026-07-16T18:00:00",
                "maxTeams": 24,
                "status": "OPEN_REGISTRATION"
              }
            ]
          }
          ''');
        }),
      );

      final tournaments = await service.getTournaments();

      expect(tournaments, hasLength(1));
      expect(tournaments.single.id, '12');
      expect(tournaments.single.title, 'Summer Cup');
      expect(tournaments.single.status, 'OPEN_REGISTRATION');
      expect(tournaments.single.maxTeams, 24);
    });

    test('keeps an empty public tournament result empty', () async {
      final service = SpectatorApiService(
        baseUrl: 'http://example.test',
        client: MockClient((request) async {
          expect(request.headers.containsKey('Authorization'), isFalse);
          return _jsonResponse(
            '{"success":true,"message":"Success","data":[]}',
          );
        }),
      );

      expect(await service.getTournaments(), isEmpty);
    });

    test('gets public tournament detail without bearer token', () async {
      final service = SpectatorApiService(
        baseUrl: 'http://example.test',
        client: MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.toString(), 'http://example.test/tournaments/12');
          expect(request.headers.containsKey('Authorization'), isFalse);

          return _jsonResponse('''
          {
            "success": true,
            "message": "Success",
            "data": {
              "id": 12,
              "name": "Summer Cup",
              "description": "National race",
              "location": "Phu Tho",
              "bannerUrl": "/uploads/tournaments/12.jpg",
              "registrationOpenAt": "2026-06-01T08:00:00",
              "registrationCloseAt": "2026-07-01T18:00:00",
              "startAt": "2026-07-15T09:00:00",
              "endAt": "2026-07-16T18:00:00",
              "rules": "Follow rules.",
              "minTeams": 8,
              "maxTeams": 24,
              "minHorsesPerOwner": 1,
              "maxHorsesPerOwner": 3,
              "status": "OPEN_REGISTRATION",
              "races": [
                {
                  "id": 5,
                  "name": "Qualifier",
                  "distance": "1200m",
                  "venueName": "Track A",
                  "scheduledStartAt": "2026-07-15T09:00:00",
                  "scheduledEndAt": "2026-07-15T10:00:00",
                  "maxParticipants": 12,
                  "participantCount": 4,
                  "entryFee": 500000,
                  "status": "SCHEDULED",
                  "prizes": [
                    {"rank": 1, "amount": 10000000, "itemName": "Cup"}
                  ]
                }
              ]
            }
          }
          ''');
        }),
      );

      final detail = await service.getTournamentDetail('12');

      expect(detail.id, '12');
      expect(detail.name, 'Summer Cup');
      expect(detail.races, hasLength(1));
      expect(detail.races.single.id, '5');
      expect(detail.races.single.prizes.single.amount, 10000000);
    });

    test('gets public race results without bearer token', () async {
      final service = SpectatorApiService(
        baseUrl: 'http://example.test',
        client: MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.toString(), 'http://example.test/races/5/results');
          expect(request.headers.containsKey('Authorization'), isFalse);

          return _jsonResponse('''
          {
            "success": true,
            "message": "Success",
            "data": [
              {
                "id": 31,
                "raceId": 5,
                "participantId": 22,
                "ownerId": 4,
                "ownerUsername": "owner01",
                "horseId": 8,
                "horseName": "Night Wind",
                "jockeyId": 9,
                "jockeyUsername": "jockey01",
                "rank": 1,
                "finishTimeMillis": 68123,
                "status": "FINISHED",
                "jockeyChallengePoints": 10,
                "jockeyPrizeAmount": 500000,
                "payoutStatus": "PAID"
              }
            ]
          }
          ''');
        }),
      );

      final results = await service.getRaceResults('5');

      expect(results, hasLength(1));
      expect(results.single.raceId, 5);
      expect(results.single.horseName, 'Night Wind');
      expect(results.single.rank, 1);
    });

    test('gets current user with bearer token', () async {
      final storage = await _storageWithToken('spectator-token');
      final service = SpectatorApiService(
        baseUrl: 'http://example.test',
        storage: storage,
        client: MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.toString(), 'http://example.test/auth/me');
          expect(request.headers['Authorization'], 'Bearer spectator-token');

          return _jsonResponse('''
          {
            "success": true,
            "message": "Success",
            "data": {
              "id": 7,
              "username": "spectator01",
              "email": "spectator@example.test",
              "fullName": "Spectator One",
              "role": "SPECTATOR",
              "avatarUrl": "/uploads/users/7.jpg"
            }
          }
          ''');
        }),
      );

      final user = await service.getCurrentUser();

      expect(user.id, 7);
      expect(user.username, 'spectator01');
      expect(user.role, 'SPECTATOR');
    });

    test('wraps missing token as SpectatorApiException', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final service = SpectatorApiService(
        baseUrl: 'http://example.test',
        storage: AuthStorage(preferences: preferences),
        client: MockClient((_) async => http.Response('{}', 200)),
      );

      expect(
        service.getCurrentUser,
        throwsA(
          isA<SpectatorApiException>().having(
            (error) => error.message,
            'message',
            contains('Phien dang nhap'),
          ),
        ),
      );
    });

    test('preserves backend error message', () async {
      final service = SpectatorApiService(
        baseUrl: 'http://example.test',
        client: MockClient((_) async {
          return _jsonResponse(
            '{"success":false,"message":"Service unavailable","data":null}',
            statusCode: 503,
          );
        }),
      );

      expect(
        service.getTournaments,
        throwsA(
          isA<SpectatorApiException>()
              .having(
                (error) => error.message,
                'message',
                'Service unavailable',
              )
              .having((error) => error.statusCode, 'statusCode', 503),
        ),
      );
    });

    test('wraps non-json response with status code', () async {
      final service = SpectatorApiService(
        baseUrl: 'http://example.test',
        client: MockClient((_) async => http.Response('not json', 500)),
      );

      expect(
        service.getTournaments,
        throwsA(
          isA<SpectatorApiException>().having(
            (error) => error.statusCode,
            'statusCode',
            500,
          ),
        ),
      );
    });
  });
}

http.Response _jsonResponse(String body, {int statusCode = 200}) {
  return http.Response.bytes(
    utf8.encode(body),
    statusCode,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
}

Future<AuthStorage> _storageWithToken(String token) async {
  SharedPreferences.setMockInitialValues({});
  final preferences = await SharedPreferences.getInstance();
  final storage = AuthStorage(preferences: preferences);
  await storage.saveSession(
    AuthSession(token: token, tokenType: 'Bearer', role: 'SPECTATOR'),
  );
  return storage;
}
