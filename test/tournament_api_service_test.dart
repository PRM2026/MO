import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:horse_racing/src/services/tournament_api_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('TournamentApiService', () {
    test('maps the public tournament summary contract', () async {
      final client = MockClient((request) async {
        expect(request.url.toString(), 'http://example.test/tournaments');
        return http.Response(
          '''
          {
            "success": true,
            "message": "Success",
            "data": [
              {
                "id": 12,
                "name": "Cúp Mùa Hè",
                "location": "",
                "provinceName": "Phú Thọ",
                "bannerUrl": "/uploads/tournaments/12.jpg",
                "registrationOpenAt": "2026-06-01T08:00:00",
                "startAt": "2026-07-15T09:00:00",
                "endAt": "2026-07-16T18:00:00",
                "maxTeams": 24,
                "status": "OPEN_REGISTRATION"
              }
            ]
          }
          ''',
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });
      final service = TournamentApiService(
        client: client,
        baseUrl: 'http://example.test',
      );

      final tournaments = await service.fetchTournaments();

      expect(tournaments, hasLength(1));
      expect(tournaments.single.id, '12');
      expect(tournaments.single.title, 'Cúp Mùa Hè');
      expect(tournaments.single.location, 'Phú Thọ');
      expect(tournaments.single.status, 'OPEN_REGISTRATION');
      expect(tournaments.single.maxTeams, 24);
      expect(tournaments.single.ownerCapacityLabel, 'Tối đa 24 đội');
      expect(tournaments.single.canOwnerJoin, isTrue);
    });

    test('keeps an empty API result empty', () async {
      final client = MockClient(
        (_) async => http.Response(
          '{"success":true,"message":"Success","data":[]}',
          200,
        ),
      );
      final service = TournamentApiService(
        client: client,
        baseUrl: 'http://example.test',
      );

      expect(await service.fetchTournaments(), isEmpty);
    });

    test('maps tournament detail and its races', () async {
      final client = MockClient(
        (_) async => http.Response.bytes(
          utf8.encode('''
          {
            "success": true,
            "message": "Success",
            "data": {
              "id": 12,
              "name": "Cúp Mùa Hè",
              "description": "Giải đua toàn quốc",
              "location": "Phú Thọ",
              "bannerUrl": "/uploads/tournaments/12.jpg",
              "registrationOpenAt": "2026-06-01T08:00:00",
              "registrationCloseAt": "2026-07-01T18:00:00",
              "startAt": "2026-07-15T09:00:00",
              "endAt": "2026-07-16T18:00:00",
              "rules": "Tuân thủ luật giải.",
              "minTeams": 8,
              "maxTeams": 24,
              "minHorsesPerOwner": 1,
              "maxHorsesPerOwner": 3,
              "status": "OPEN_REGISTRATION",
              "races": [
                {
                  "id": 5,
                  "name": "Vòng loại",
                  "distance": "1200m",
                  "venueName": "Đường đua A",
                  "scheduledStartAt": "2026-07-15T09:00:00",
                  "scheduledEndAt": "2026-07-15T10:00:00",
                  "maxParticipants": 12,
                  "participantCount": 4,
                  "entryFee": 500000,
                  "status": "SCHEDULED",
                  "prizes": [
                    {"rank": 1, "amount": 10000000, "itemName": "Cúp"}
                  ]
                }
              ]
            }
          }
          '''),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        ),
      );
      final service = TournamentApiService(
        client: client,
        baseUrl: 'http://example.test',
      );

      final detail = await service.fetchTournamentDetail('12');

      expect(detail.name, 'Cúp Mùa Hè');
      expect(detail.statusLabel, 'Mở đăng ký');
      expect(detail.teamRangeLabel, '8 - 24 đội');
      expect(detail.races, hasLength(1));
      expect(detail.races.single.name, 'Vòng loại');
      expect(detail.races.single.participantLabel, '4/12 người tham gia');
      expect(detail.races.single.prizes.single.amount, 10000000);
    });

    test('throws the backend message when the request fails', () async {
      final client = MockClient(
        (_) async => http.Response(
          '{"success":false,"message":"Service unavailable","data":null}',
          503,
        ),
      );
      final service = TournamentApiService(
        client: client,
        baseUrl: 'http://example.test',
      );

      expect(
        service.fetchTournaments,
        throwsA(
          isA<TournamentApiException>().having(
            (error) => error.message,
            'message',
            'Service unavailable',
          ),
        ),
      );
    });
  });
}
