import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:horse_racing/src/models/auth_session.dart';
import 'package:horse_racing/src/services/api_client.dart';
import 'package:horse_racing/src/services/api_exception.dart';
import 'package:horse_racing/src/services/auth_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('getList sends bearer token and maps ApiResponse list', () async {
    final storage = await _storageWithToken('owner-token');
    final client = ApiClient(
      baseUrl: 'http://example.test',
      storage: storage,
      client: MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.toString(), 'http://example.test/owner/horses');
        expect(request.headers['Accept'], 'application/json');
        expect(request.headers['Authorization'], 'Bearer owner-token');

        return http.Response.bytes(
          utf8.encode('''
          {
            "success": true,
            "message": "Success",
            "data": [
              {"id": 1, "name": "Night Wind"}
            ]
          }
          '''),
          200,
        );
      }),
    );

    final items = await client.getList(
      '/owner/horses',
      (json) => json['name'] as String,
    );

    expect(items, ['Night Wind']);
  });

  test('public getObject does not require bearer token', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final client = ApiClient(
      baseUrl: 'http://example.test/',
      storage: AuthStorage(preferences: preferences),
      client: MockClient((request) async {
        expect(request.url.toString(), 'http://example.test/tournaments/3');
        expect(request.headers.containsKey('Authorization'), isFalse);

        return http.Response.bytes(
          utf8.encode('''
          {
            "success": true,
            "message": "Success",
            "data": {"id": 3, "title": "Summer Cup"}
          }
          '''),
          200,
        );
      }),
    );

    final title = await client.getObject(
      'tournaments/3',
      (json) => json['title'] as String,
      authenticated: false,
    );

    expect(title, 'Summer Cup');
  });

  test('postObject sends json body and content type', () async {
    final storage = await _storageWithToken('owner-token');
    final client = ApiClient(
      baseUrl: 'http://example.test',
      storage: storage,
      client: MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.toString(), 'http://example.test/owner/horses');
        expect(request.headers['Content-Type'], 'application/json');
        expect(jsonDecode(request.body), {'name': 'Night Wind'});

        return http.Response.bytes(
          utf8.encode('''
          {
            "success": true,
            "message": "Created",
            "data": {"id": 11, "name": "Night Wind"}
          }
          '''),
          201,
        );
      }),
    );

    final name = await client.postObject('/owner/horses', {
      'name': 'Night Wind',
    }, (json) => json['name'] as String);

    expect(name, 'Night Wind');
  });

  test('throws ApiException when authenticated request has no token', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final client = ApiClient(
      baseUrl: 'http://example.test',
      storage: AuthStorage(preferences: preferences),
      client: MockClient((_) async => http.Response('{}', 200)),
    );

    expect(
      () => client.getObject('/owner/dashboard', (json) => json),
      throwsA(isA<ApiException>()),
    );
  });

  test('throws ApiException with BE message on business error', () async {
    final storage = await _storageWithToken('owner-token');
    final client = ApiClient(
      baseUrl: 'http://example.test',
      storage: storage,
      client: MockClient((_) async {
        return http.Response.bytes(
          utf8.encode('''
          {
            "success": false,
            "message": "Horse name is required",
            "data": {"name": ["Required"]}
          }
          '''),
          400,
        );
      }),
    );

    expect(
      () => client.getObject('/owner/horses/1', (json) => json),
      throwsA(
        isA<ApiException>().having(
          (error) => error.message,
          'message',
          'Horse name is required',
        ),
      ),
    );
  });

  test('uses first validation message when BE message is empty', () async {
    final storage = await _storageWithToken('owner-token');
    final client = ApiClient(
      baseUrl: 'http://example.test',
      storage: storage,
      client: MockClient((_) async {
        return http.Response.bytes(
          utf8.encode('''
          {
            "success": false,
            "message": "",
            "data": {"name": ["Required"]}
          }
          '''),
          400,
        );
      }),
    );

    expect(
      () => client.getList('/owner/horses', (json) => json),
      throwsA(
        isA<ApiException>().having(
          (error) => error.message,
          'message',
          'Required',
        ),
      ),
    );
  });

  test('throws ApiException for non-json response', () async {
    final storage = await _storageWithToken('owner-token');
    final client = ApiClient(
      baseUrl: 'http://example.test',
      storage: storage,
      client: MockClient((_) async => http.Response('not json', 500)),
    );

    expect(
      () => client.getObject('/owner/dashboard', (json) => json),
      throwsA(
        isA<ApiException>().having(
          (error) => error.statusCode,
          'statusCode',
          500,
        ),
      ),
    );
  });
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
