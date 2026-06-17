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

  test('calls jockey invitations API with bearer token', () async {
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

        return http.Response.bytes(
          utf8.encode('''
          {
            "success": true,
            "message": "Success",
            "data": [
              {
                "id": 7,
                "ownerUsername": "stable_owner",
                "horseName": "Night Wind",
                "status": "PENDING"
              }
            ]
          }
          '''),
          200,
        );
      }),
    );

    final invitations = await service.getJockeyInvitations();

    expect(invitations.single.id, 7);
    expect(invitations.single.horseName, 'Night Wind');
    expect(invitations.single.statusCode, 'PENDING');
  });

  test('acceptInvitation sends optional note as json body', () async {
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
        expect(request.headers['Content-Type'], 'application/json');
        expect(request.headers['Authorization'], 'Bearer jockey-token');
        expect(jsonDecode(request.body), {'note': 'Ready'});

        return http.Response.bytes(
          utf8.encode('''
          {
            "success": true,
            "message": "Accepted",
            "data": {
              "id": 7,
              "status": "ACCEPTED",
              "responseNote": "Ready"
            }
          }
          '''),
          200,
        );
      }),
    );

    final invitation = await service.acceptInvitation(7, note: ' Ready ');

    expect(invitation.statusCode, 'ACCEPTED');
    expect(invitation.responseNote, 'Ready');
  });

  test('wraps ApiClient errors as JockeyInvitationApiException', () async {
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

Future<AuthStorage> _storageWithToken(String token) async {
  SharedPreferences.setMockInitialValues({});
  final preferences = await SharedPreferences.getInstance();
  final storage = AuthStorage(preferences: preferences);
  await storage.saveSession(
    AuthSession(token: token, tokenType: 'Bearer', role: 'JOCKEY'),
  );
  return storage;
}
