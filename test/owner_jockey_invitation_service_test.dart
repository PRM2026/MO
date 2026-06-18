import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:horse_racing/src/models/auth_session.dart';
import 'package:horse_racing/src/models/owner_jockey_invitation.dart';
import 'package:horse_racing/src/services/auth_storage.dart';
import 'package:horse_racing/src/services/owner_jockey_invitation_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OwnerJockeyInvitation models', () {
    test('parses full invitation response', () {
      final invitation = OwnerJockeyInvitation.fromJson(_invitationJson());

      expect(invitation.id, '17');
      expect(invitation.ownerId, 3);
      expect(invitation.ownerUsername, 'owner01');
      expect(invitation.jockeyId, 9);
      expect(invitation.jockeyUsername, 'jockey09');
      expect(invitation.jockeyProfileId, 99);
      expect(invitation.horseId, 7);
      expect(invitation.horseName, 'Night Wind');
      expect(invitation.raceId, 21);
      expect(invitation.raceName, 'Spring Sprint');
      expect(invitation.tournamentId, 5);
      expect(invitation.tournamentName, 'Spring Cup');
      expect(invitation.statusCode, 'ACCEPTED');
      expect(invitation.statusLabel, 'Đã nhận');
      expect(invitation.message, 'Ready?');
      expect(invitation.responseNote, 'Ready');
      expect(invitation.remunerationAmount, 1500000);
      expect(invitation.respondedAt, isNotNull);
      expect(invitation.cancelledAt, isNull);
      expect(invitation.createdAt, isNotNull);
      expect(invitation.updatedAt, isNotNull);
    });

    test('parses missing optional data and status fallback', () {
      final pending = OwnerJockeyInvitation.fromJson({'id': 1});
      final unknown = OwnerJockeyInvitation.fromJson({
        'id': 2,
        'status': 'EXPIRED',
      });

      expect(pending.statusCode, 'PENDING');
      expect(pending.statusLabel, 'Chờ phản hồi');
      expect(pending.horseName, isNull);

      expect(unknown.statusCode, 'EXPIRED');
      expect(unknown.statusLabel, 'EXPIRED');
    });

    test('builds invitation form body and validates input', () {
      const data = OwnerJockeyInvitationFormData(
        horseId: 7,
        raceId: 21,
        jockeyId: 9,
        remunerationAmount: 1500000,
        message: ' Ready? ',
      );
      const emptyMessage = OwnerJockeyInvitationFormData(
        horseId: 7,
        raceId: 21,
        jockeyId: 9,
        remunerationAmount: 0,
        message: ' ',
      );

      expect(data.validate(), isNull);
      expect(data.toJson(), {
        'horseId': 7,
        'raceId': 21,
        'jockeyId': 9,
        'remunerationAmount': 1500000,
        'message': 'Ready?',
      });
      expect(emptyMessage.toJson(), {
        'horseId': 7,
        'raceId': 21,
        'jockeyId': 9,
        'remunerationAmount': 0,
      });

      expect(
        const OwnerJockeyInvitationFormData(
          raceId: 21,
          jockeyId: 9,
          remunerationAmount: 1,
        ).validate(),
        isNotNull,
      );
      expect(
        const OwnerJockeyInvitationFormData(
          horseId: 7,
          raceId: 21,
          jockeyId: 9,
          remunerationAmount: -1,
        ).validate(),
        'Thù lao không được nhỏ hơn 0.',
      );
      expect(
        OwnerJockeyInvitationFormData(
          horseId: 7,
          raceId: 21,
          jockeyId: 9,
          remunerationAmount: 1,
          message: 'x' * 1001,
        ).validate(),
        'Lời nhắn tối đa 1000 ký tự.',
      );
    });

    test(
      'parses accepted and available jockeys with missing optional fields',
      () {
        final accepted = OwnerAcceptedJockey.fromJson({
          'id': 17,
          'jockey': {'id': 9, 'username': 'jockey09'},
          'horse': {'id': 7, 'name': 'Night Wind'},
          'respondedAt': '2026-07-01T10:00:00',
        });
        final available = OwnerAvailableJockey.fromJson({
          'id': 9,
          'username': 'jockey09',
          'profile': {'id': 99, 'fullName': 'Fast Rider', 'rating': 4.5},
        });

        expect(accepted.id, '17');
        expect(accepted.jockeyId, 9);
        expect(accepted.jockeyUsername, 'jockey09');
        expect(accepted.horseId, 7);
        expect(accepted.horseName, 'Night Wind');
        expect(accepted.acceptedAt, isNotNull);

        expect(available.id, 9);
        expect(available.username, 'jockey09');
        expect(available.profileId, 99);
        expect(available.fullName, 'Fast Rider');
        expect(available.rating, 4.5);
      },
    );
  });

  group('OwnerJockeyInvitationService', () {
    test('fetches available jockeys with bearer token', () async {
      final service = await _service((request) async {
        expect(request.method, 'GET');
        expect(request.url.toString(), 'http://example.test/users/jockeys');
        expect(request.headers['Accept'], 'application/json');
        expect(request.headers['Authorization'], 'Bearer owner-token');
        return _jsonResponse([
          {'id': 9, 'username': 'jockey09', 'fullName': 'Fast Rider'},
        ]);
      });

      final jockeys = await service.getAvailableJockeys();

      expect(jockeys, hasLength(1));
      expect(jockeys.single.id, 9);
      expect(jockeys.single.fullName, 'Fast Rider');
    });

    test('fetches empty owner invitation list', () async {
      final service = await _service((request) async {
        expect(request.method, 'GET');
        expect(
          request.url.toString(),
          'http://example.test/owner/jockey-invitations',
        );
        expect(request.headers['Authorization'], 'Bearer owner-token');
        return _jsonResponse([]);
      });

      expect(await service.getInvitations(), isEmpty);
    });

    test('fetches invitation detail', () async {
      final service = await _service((request) async {
        expect(request.method, 'GET');
        expect(
          request.url.toString(),
          'http://example.test/owner/jockey-invitations/17',
        );
        return _jsonResponse(_invitationJson());
      });

      final invitation = await service.getInvitation('17');

      expect(invitation.id, '17');
      expect(invitation.statusCode, 'ACCEPTED');
    });

    test('creates invitation with json body', () async {
      final service = await _service((request) async {
        expect(request.method, 'POST');
        expect(
          request.url.toString(),
          'http://example.test/owner/jockey-invitations',
        );
        expect(request.headers['Content-Type'], 'application/json');
        expect(request.headers['Authorization'], 'Bearer owner-token');
        expect(jsonDecode(request.body), {
          'horseId': 7,
          'raceId': 21,
          'jockeyId': 9,
          'remunerationAmount': 1500000,
          'message': 'Ready?',
        });
        return _jsonResponse(_invitationJson(status: 'PENDING'), 201);
      });

      final invitation = await service.createInvitation(
        const OwnerJockeyInvitationFormData(
          horseId: 7,
          raceId: 21,
          jockeyId: 9,
          remunerationAmount: 1500000,
          message: ' Ready? ',
        ),
      );

      expect(invitation.statusCode, 'PENDING');
    });

    test('rejects invalid create data before calling API', () async {
      final service = await _service((_) async {
        fail('API should not be called for invalid form data');
      });

      expect(
        () => service.createInvitation(
          const OwnerJockeyInvitationFormData(
            horseId: 7,
            raceId: 21,
            jockeyId: 9,
            remunerationAmount: -1,
          ),
        ),
        throwsA(isA<OwnerJockeyInvitationApiException>()),
      );
    });

    test('fetches accepted jockeys', () async {
      final service = await _service((request) async {
        expect(request.method, 'GET');
        expect(request.url.toString(), 'http://example.test/owners/me/jockeys');
        return _jsonResponse([
          {
            'id': 17,
            'jockeyId': 9,
            'jockeyUsername': 'jockey09',
            'horseId': 7,
            'horseName': 'Night Wind',
          },
        ]);
      });

      final accepted = await service.getAcceptedJockeys();

      expect(accepted, hasLength(1));
      expect(accepted.single.jockeyId, 9);
      expect(accepted.single.horseName, 'Night Wind');
    });

    test('cancels invitation and parses returned object', () async {
      final service = await _service((request) async {
        expect(request.method, 'PUT');
        expect(
          request.url.toString(),
          'http://example.test/owner/jockey-invitations/17/cancel',
        );
        expect(request.headers['Authorization'], 'Bearer owner-token');
        return _jsonResponse(_invitationJson(status: 'CANCELLED'));
      });

      final invitation = await service.cancelInvitation('17');

      expect(invitation?.statusCode, 'CANCELLED');
      expect(invitation?.statusLabel, 'Đã hủy');
    });

    test('cancels invitation when API returns null data', () async {
      final service = await _service((request) async {
        expect(request.method, 'PUT');
        return http.Response(
          jsonEncode({'success': true, 'message': 'Cancelled', 'data': null}),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      expect(await service.cancelInvitation('17'), isNull);
    });

    test('wraps business errors and validation errors', () async {
      final business = await _service((_) async {
        return http.Response(
          jsonEncode({
            'success': false,
            'message': 'Wallet balance is not enough',
            'data': null,
          }),
          400,
        );
      });
      final validation = await _service((_) async {
        return http.Response(
          jsonEncode({
            'success': false,
            'message': '',
            'data': {
              'raceId': ['Race is closed'],
            },
          }),
          422,
        );
      });

      expect(
        business.getInvitations,
        throwsA(
          isA<OwnerJockeyInvitationApiException>().having(
            (error) => error.message,
            'message',
            'Wallet balance is not enough',
          ),
        ),
      );
      expect(
        validation.getInvitations,
        throwsA(
          isA<OwnerJockeyInvitationApiException>().having(
            (error) => error.message,
            'message',
            'Race is closed',
          ),
        ),
      );
    });

    test('wraps non-json responses and missing token', () async {
      final nonJson = await _service((_) async {
        return http.Response('server unavailable', 500);
      });

      expect(
        nonJson.getInvitations,
        throwsA(isA<OwnerJockeyInvitationApiException>()),
      );

      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final noToken = OwnerJockeyInvitationService(
        baseUrl: 'http://example.test',
        storage: AuthStorage(preferences: preferences),
        client: MockClient((_) async => _jsonResponse([])),
      );

      expect(
        noToken.getInvitations,
        throwsA(isA<OwnerJockeyInvitationApiException>()),
      );
    });
  });
}

Future<OwnerJockeyInvitationService> _service(
  Future<http.Response> Function(http.Request request) handler,
) async {
  final storage = await _storageWithToken('owner-token');
  return OwnerJockeyInvitationService(
    baseUrl: 'http://example.test',
    storage: storage,
    client: MockClient(handler),
  );
}

Future<AuthStorage> _storageWithToken(String token) async {
  SharedPreferences.setMockInitialValues({});
  final preferences = await SharedPreferences.getInstance();
  final storage = AuthStorage(preferences: preferences);
  await storage.saveSession(
    AuthSession(token: token, tokenType: 'Bearer', role: 'OWNER'),
  );
  return storage;
}

http.Response _jsonResponse(Object? data, [int statusCode = 200]) {
  return http.Response.bytes(
    utf8.encode(
      jsonEncode({'success': true, 'message': 'Success', 'data': data}),
    ),
    statusCode,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
}

Map<String, dynamic> _invitationJson({String status = 'ACCEPTED'}) {
  return {
    'id': 17,
    'ownerId': 3,
    'ownerUsername': 'owner01',
    'jockeyId': 9,
    'jockeyUsername': 'jockey09',
    'jockeyProfileId': 99,
    'horseId': 7,
    'horseName': 'Night Wind',
    'raceId': 21,
    'raceName': 'Spring Sprint',
    'tournamentId': 5,
    'tournamentName': 'Spring Cup',
    'status': status,
    'message': 'Ready?',
    'responseNote': status == 'ACCEPTED' ? 'Ready' : null,
    'remunerationAmount': 1500000,
    'respondedAt': status == 'ACCEPTED' ? '2026-07-01T10:00:00' : null,
    'cancelledAt': status == 'CANCELLED' ? '2026-07-01T11:00:00' : null,
    'createdAt': '2026-06-30T09:00:00',
    'updatedAt': '2026-07-01T10:00:00',
  };
}
