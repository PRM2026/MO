import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:horse_racing/src/models/auth_session.dart';
import 'package:horse_racing/src/services/auth_storage.dart';
import 'package:horse_racing/src/services/jockey_invitation_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('JockeyInvitationService read APIs', () {
    test('loads list with bearer token and parses full response', () async {
      final storage = await _storageWithToken('jockey-token');
      final service = JockeyInvitationService(
        baseUrl: 'http://example.test',
        storage: storage,
        client: MockClient((request) async {
          expect(request.method, 'GET');
          expect(
            request.url.toString(),
            'http://example.test/jockey/invitations',
          );
          expect(request.headers['Accept'], 'application/json');
          expect(request.headers['Authorization'], 'Bearer jockey-token');
          return _jsonResponse({
            'success': true,
            'message': 'Success',
            'data': [_invitationJson()],
          });
        }),
      );

      final invitation = (await service.getJockeyInvitations()).single;

      expect(invitation.id, '7');
      expect(invitation.ownerId, '3');
      expect(invitation.jockeyId, '5');
      expect(invitation.jockeyProfileId, '11');
      expect(invitation.horseId, '21');
      expect(invitation.raceId, '31');
      expect(invitation.tournamentId, '41');
      expect(invitation.remunerationAmount, 500000);
      expect(invitation.statusCode, 'PENDING');
      expect(invitation.createdAt, DateTime.parse('2026-06-18T08:00:00'));
      expect(invitation.updatedAt, DateTime.parse('2026-06-18T09:00:00'));
    });

    test('loads detail using the invitation id', () async {
      final storage = await _storageWithToken('jockey-token');
      final service = JockeyInvitationService(
        baseUrl: 'http://example.test',
        storage: storage,
        client: MockClient((request) async {
          expect(request.method, 'GET');
          expect(
            request.url.toString(),
            'http://example.test/jockey/invitations/7',
          );
          expect(request.headers['Authorization'], 'Bearer jockey-token');
          return _jsonResponse({
            'success': true,
            'message': 'Success',
            'data': _invitationJson(
              status: 'ACCEPTED',
              responseNote: 'Sẵn sàng tham gia',
              respondedAt: '2026-06-18T10:00:00',
            ),
          });
        }),
      );

      final invitation = await service.getJockeyInvitation('7');

      expect(invitation.horseName, 'Night Wind');
      expect(invitation.statusLabel, 'Đã nhận');
      expect(invitation.responseNote, 'Sẵn sàng tham gia');
      expect(invitation.respondedAt, DateTime.parse('2026-06-18T10:00:00'));
    });

    test('wraps success false with backend message', () async {
      final storage = await _storageWithToken('jockey-token');
      final service = JockeyInvitationService(
        baseUrl: 'http://example.test',
        storage: storage,
        client: MockClient(
          (_) async => _jsonResponse({
            'success': false,
            'message': 'Invitation not found',
            'data': null,
          }, statusCode: 404),
        ),
      );

      expect(
        () => service.getJockeyInvitation('99'),
        throwsA(
          isA<JockeyInvitationApiException>().having(
            (error) => error.message,
            'message',
            'Invitation not found',
          ),
        ),
      );
    });

    test('wraps validation data when backend message is empty', () async {
      final storage = await _storageWithToken('jockey-token');
      final service = JockeyInvitationService(
        baseUrl: 'http://example.test',
        storage: storage,
        client: MockClient(
          (_) async => _jsonResponse({
            'success': false,
            'message': '',
            'data': {
              'id': ['Invitation id is invalid'],
            },
          }, statusCode: 400),
        ),
      );

      expect(
        service.getJockeyInvitations,
        throwsA(
          isA<JockeyInvitationApiException>().having(
            (error) => error.message,
            'message',
            'Invitation id is invalid',
          ),
        ),
      );
    });

    test('wraps non-json response as invitation exception', () async {
      final storage = await _storageWithToken('jockey-token');
      final service = JockeyInvitationService(
        baseUrl: 'http://example.test',
        storage: storage,
        client: MockClient((_) async => http.Response('not-json', 500)),
      );

      expect(
        service.getJockeyInvitations,
        throwsA(
          isA<JockeyInvitationApiException>().having(
            (error) => error.statusCode,
            'statusCode',
            500,
          ),
        ),
      );
    });
  });

  group('JockeyInvitationService action APIs', () {
    test('accept sends trimmed note as json body', () async {
      final storage = await _storageWithToken('jockey-token');
      final service = JockeyInvitationService(
        baseUrl: 'http://example.test',
        storage: storage,
        client: MockClient((request) async {
          expect(request.method, 'PUT');
          expect(
            request.url.toString(),
            'http://example.test/jockey/invitations/7/accept',
          );
          expect(request.headers['Authorization'], 'Bearer jockey-token');
          expect(request.headers['Content-Type'], 'application/json');
          expect(jsonDecode(request.body), {'note': 'Ready'});
          return _jsonResponse({
            'success': true,
            'message': 'Accepted',
            'data': _invitationJson(status: 'ACCEPTED', responseNote: 'Ready'),
          });
        }),
      );

      final invitation = await service.acceptInvitation('7', note: ' Ready ');

      expect(invitation.statusCode, 'ACCEPTED');
      expect(invitation.responseNote, 'Ready');
    });

    test('reject sends note to jockey reject endpoint', () async {
      final storage = await _storageWithToken('jockey-token');
      final service = JockeyInvitationService(
        baseUrl: 'http://example.test',
        storage: storage,
        client: MockClient((request) async {
          expect(request.method, 'PUT');
          expect(
            request.url.toString(),
            'http://example.test/jockey/invitations/7/reject',
          );
          expect(jsonDecode(request.body), {'note': 'Busy'});
          return _jsonResponse({
            'success': true,
            'message': 'Rejected',
            'data': _invitationJson(status: 'REJECTED', responseNote: 'Busy'),
          });
        }),
      );

      final invitation = await service.rejectInvitation('7', note: 'Busy');

      expect(invitation.statusCode, 'REJECTED');
      expect(invitation.responseNote, 'Busy');
    });

    test('empty action note sends empty json object', () async {
      final storage = await _storageWithToken('jockey-token');
      final service = JockeyInvitationService(
        baseUrl: 'http://example.test',
        storage: storage,
        client: MockClient((request) async {
          expect(request.method, 'PUT');
          expect(jsonDecode(request.body), <String, dynamic>{});
          return _jsonResponse({
            'success': true,
            'message': 'Accepted',
            'data': _invitationJson(status: 'ACCEPTED'),
          });
        }),
      );

      final invitation = await service.acceptInvitation('7', note: '   ');

      expect(invitation.statusCode, 'ACCEPTED');
    });

    test('action wraps backend validation error', () async {
      final storage = await _storageWithToken('jockey-token');
      final service = JockeyInvitationService(
        baseUrl: 'http://example.test',
        storage: storage,
        client: MockClient(
          (_) async => _jsonResponse({
            'success': false,
            'message': '',
            'data': {
              'note': ['Note must be at most 1000 characters'],
            },
          }, statusCode: 400),
        ),
      );

      expect(
        () => service.rejectInvitation('7', note: 'x' * 1001),
        throwsA(
          isA<JockeyInvitationApiException>().having(
            (error) => error.message,
            'message',
            'Note must be at most 1000 characters',
          ),
        ),
      );
    });
  });

  test('missing token is wrapped as invitation exception', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final service = JockeyInvitationService(
      baseUrl: 'http://example.test',
      storage: AuthStorage(preferences: preferences),
      client: MockClient((_) async => http.Response('{}', 200)),
    );

    expect(
      service.getJockeyInvitations,
      throwsA(isA<JockeyInvitationApiException>()),
    );
  });
}

Map<String, dynamic> _invitationJson({
  String status = 'PENDING',
  String? responseNote,
  String? respondedAt,
}) {
  return {
    'id': 7,
    'ownerId': 3,
    'ownerUsername': 'stable_owner',
    'jockeyId': 5,
    'jockeyUsername': 'minh_jockey',
    'jockeyProfileId': 11,
    'horseId': 21,
    'horseName': 'Night Wind',
    'raceId': 31,
    'raceName': 'Autumn Sprint',
    'tournamentId': 41,
    'tournamentName': 'National Cup',
    'status': status,
    'message': 'Mời bạn tham gia cuộc đua.',
    'responseNote': responseNote,
    'remunerationAmount': 500000,
    'respondedAt': respondedAt,
    'cancelledAt': null,
    'createdAt': '2026-06-18T08:00:00',
    'updatedAt': '2026-06-18T09:00:00',
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
