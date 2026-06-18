import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:horse_racing/src/models/auth_session.dart';
import 'package:horse_racing/src/models/owner_horse_item.dart';
import 'package:horse_racing/src/services/auth_storage.dart';
import 'package:horse_racing/src/services/owner_horse_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OwnerHorseDetail', () {
    test('parses full response fields', () {
      final detail = OwnerHorseDetail.fromJson(_horseDetailJson());

      expect(detail.id, '7');
      expect(detail.ownerId, 3);
      expect(detail.ownerUsername, 'owner01');
      expect(detail.name, 'Bão Đêm');
      expect(detail.breed, 'Thoroughbred');
      expect(detail.age, 4);
      expect(detail.gender, 'Đực');
      expect(detail.color, 'Đen');
      expect(detail.heightCm, 165.5);
      expect(detail.weightKg, 480);
      expect(detail.documentUrl, endsWith('/uploads/horses/7.pdf'));
      expect(detail.statusCode, 'APPROVED');
      expect(detail.statusLabel, 'Đã duyệt');
      expect(detail.reviewReason, 'OK');
      expect(detail.performance.wins, 2);
      expect(detail.raceHistory.single.raceName, 'Spring Sprint');
      expect(detail.createdAt, isNotNull);
      expect(detail.updatedAt, isNotNull);
    });

    test('parses optional missing fields without fake data', () {
      final detail = OwnerHorseDetail.fromJson({'id': 8, 'status': 'PENDING'});

      expect(detail.id, '8');
      expect(detail.ownerId, isNull);
      expect(detail.ownerUsername, isNull);
      expect(detail.name, 'Ngựa chưa đặt tên');
      expect(detail.breed, '—');
      expect(detail.statusLabel, 'Chờ duyệt');
      expect(detail.raceHistory, isEmpty);
      expect(detail.createdAt, isNull);
      expect(detail.updatedAt, isNull);
    });
  });

  group('OwnerHorseFormData', () {
    test('builds create fields and file paths', () {
      const data = OwnerHorseFormData(
        name: ' Night Wind ',
        breed: 'Thoroughbred',
        age: 4,
        gender: 'Đực',
        color: 'Đen',
        heightCm: 165.5,
        weightKg: 480,
        imagePath: 'C:/tmp/horse.jpg',
        documentPath: 'C:/tmp/horse.pdf',
      );

      expect(data.toFields(includeEmptyName: true), {
        'name': 'Night Wind',
        'breed': 'Thoroughbred',
        'age': '4',
        'gender': 'Đực',
        'color': 'Đen',
        'heightCm': '165.5',
        'weightKg': '480',
      });
      expect(data.toFilePaths(), {
        'image': 'C:/tmp/horse.jpg',
        'document': 'C:/tmp/horse.pdf',
      });
    });

    test('omits empty fields for update', () {
      const data = OwnerHorseFormData(
        name: ' ',
        breed: '',
        color: 'Nâu',
        imagePath: '',
      );

      expect(data.toFields(includeEmptyName: false), {'color': 'Nâu'});
      expect(data.toFilePaths(), isEmpty);
    });
  });

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
                "documentUrl": "/uploads/horses/7.pdf",
                "status": "APPROVED",
                "performance": {
                  "totalRaces": 5,
                  "wins": 2,
                  "winRate": 40
                },
                "raceHistory": [
                  {
                    "id": 15,
                    "raceName": "Spring Sprint",
                    "tournamentName": "Spring Cup",
                    "scheduledStartAt": "2026-07-15T09:00:00",
                    "rank": 2,
                    "status": "COMPLETED",
                    "result": "Finished"
                  }
                ]
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
      expect(horses.single.documentUrl, endsWith('/uploads/horses/7.pdf'));
      expect(horses.single.heightCm, 165.5);
      expect(horses.single.weightKg, 480);
      expect(horses.single.performance.totalRaces, 5);
      expect(horses.single.performance.wins, 2);
      expect(horses.single.performance.winRate, 40);
      expect(horses.single.raceHistory, hasLength(1));
      expect(horses.single.raceHistory.single.raceName, 'Spring Sprint');
      expect(horses.single.raceHistory.single.tournamentName, 'Spring Cup');
      expect(horses.single.raceHistory.single.rank, 2);
    },
  );

  test('keeps an empty owner horses API result empty', () async {
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

    final service = OwnerHorseService(
      client: MockClient(
        (_) async => http.Response(
          '{"success":true,"message":"Success","data":[]}',
          200,
        ),
      ),
      baseUrl: 'http://example.test',
      storage: storage,
    );

    expect(await service.getOwnerHorses(), isEmpty);
  });

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

  test('gets owner horse detail with bearer token', () async {
    final storage = await _storageWithToken('owner-token');
    final service = OwnerHorseService(
      client: MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.toString(), 'http://example.test/owner/horses/7');
        expect(request.headers['Authorization'], 'Bearer owner-token');
        return http.Response.bytes(
          utf8.encode(_apiObject(_horseDetailJson())),
          200,
        );
      }),
      baseUrl: 'http://example.test',
      storage: storage,
    );

    final detail = await service.getOwnerHorse('7');

    expect(detail.id, '7');
    expect(detail.ownerUsername, 'owner01');
  });

  test('creates owner horse using multipart fields and files', () async {
    final storage = await _storageWithToken('owner-token');
    final files = _TempHorseFiles.create();
    addTearDown(files.dispose);

    final service = OwnerHorseService(
      client: _MultipartInspectingClient(
        expectedMethod: 'POST',
        expectedUrl: 'http://example.test/owner/horses',
        expectedFields: {
          'name': 'Night Wind',
          'breed': 'Thoroughbred',
          'age': '4',
        },
        expectedFileFields: {'image', 'document'},
      ),
      baseUrl: 'http://example.test',
      storage: storage,
    );

    final detail = await service.createHorse(
      OwnerHorseFormData(
        name: 'Night Wind',
        breed: 'Thoroughbred',
        age: 4,
        imagePath: files.image.path,
        documentPath: files.document.path,
      ),
    );

    expect(detail.id, '7');
  });

  test('rejects create without a horse name before multipart upload', () async {
    final storage = await _storageWithToken('owner-token');
    final service = OwnerHorseService(
      client: MockClient((_) async => http.Response('{}', 500)),
      baseUrl: 'http://example.test',
      storage: storage,
    );

    expect(
      () => service.createHorse(const OwnerHorseFormData(name: ' ')),
      throwsA(
        isA<OwnerApiException>().having(
          (error) => error.message,
          'message',
          'Vui lòng nhập tên ngựa.',
        ),
      ),
    );
  });

  test('updates owner horse using multipart fields and files', () async {
    final storage = await _storageWithToken('owner-token');
    final files = _TempHorseFiles.create();
    addTearDown(files.dispose);

    final service = OwnerHorseService(
      client: _MultipartInspectingClient(
        expectedMethod: 'PUT',
        expectedUrl: 'http://example.test/owner/horses/7',
        expectedFields: {'color': 'Nâu'},
        expectedFileFields: {'document'},
      ),
      baseUrl: 'http://example.test',
      storage: storage,
    );

    final detail = await service.updateHorse(
      '7',
      OwnerHorseFormData(color: 'Nâu', documentPath: files.document.path),
    );

    expect(detail.id, '7');
  });

  test('deletes owner horse with bearer token', () async {
    final storage = await _storageWithToken('owner-token');
    final service = OwnerHorseService(
      client: MockClient((request) async {
        expect(request.method, 'DELETE');
        expect(request.url.toString(), 'http://example.test/owner/horses/7');
        expect(request.headers['Authorization'], 'Bearer owner-token');
        return http.Response(
          '{"success":true,"message":"Deleted","data":null}',
          200,
        );
      }),
      baseUrl: 'http://example.test',
      storage: storage,
    );

    await expectLater(service.deleteHorse('7'), completes);
  });

  test('wraps backend errors as OwnerApiException', () async {
    final storage = await _storageWithToken('owner-token');
    final service = OwnerHorseService(
      client: MockClient(
        (_) async => http.Response(
          '{"success":false,"message":"","data":{"name":["Required"]}}',
          400,
        ),
      ),
      baseUrl: 'http://example.test',
      storage: storage,
    );

    expect(
      () => service.getOwnerHorse('7'),
      throwsA(
        isA<OwnerApiException>().having(
          (error) => error.message,
          'message',
          'Required',
        ),
      ),
    );
  });

  test('wraps non-json responses as OwnerApiException', () async {
    final storage = await _storageWithToken('owner-token');
    final service = OwnerHorseService(
      client: MockClient((_) async => http.Response('not json', 500)),
      baseUrl: 'http://example.test',
      storage: storage,
    );

    expect(() => service.getOwnerHorse('7'), throwsA(isA<OwnerApiException>()));
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

Map<String, dynamic> _horseDetailJson() {
  return {
    'id': 7,
    'ownerId': 3,
    'ownerUsername': 'owner01',
    'name': 'Bão Đêm',
    'breed': 'Thoroughbred',
    'age': 4,
    'gender': 'Đực',
    'color': 'Đen',
    'heightCm': 165.5,
    'weightKg': 480,
    'imageUrl': '/uploads/horses/7.jpg',
    'documentUrl': '/uploads/horses/7.pdf',
    'status': 'APPROVED',
    'reviewReason': 'OK',
    'performance': {'totalRaces': 5, 'wins': 2, 'winRate': 40},
    'raceHistory': [
      {
        'id': 15,
        'raceName': 'Spring Sprint',
        'tournamentName': 'Spring Cup',
        'scheduledStartAt': '2026-07-15T09:00:00',
        'rank': 2,
        'status': 'COMPLETED',
        'result': 'Finished',
      },
    ],
    'createdAt': '2026-06-01T08:00:00',
    'updatedAt': '2026-06-02T08:00:00',
  };
}

String _apiObject(Map<String, dynamic> data) {
  return jsonEncode({'success': true, 'message': 'Success', 'data': data});
}

class _MultipartInspectingClient extends http.BaseClient {
  _MultipartInspectingClient({
    required this.expectedMethod,
    required this.expectedUrl,
    required this.expectedFields,
    required this.expectedFileFields,
  });

  final String expectedMethod;
  final String expectedUrl;
  final Map<String, String> expectedFields;
  final Set<String> expectedFileFields;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    expect(request.method, expectedMethod);
    expect(request.url.toString(), expectedUrl);
    expect(request.headers['Authorization'], 'Bearer owner-token');
    expect(request, isA<http.MultipartRequest>());

    final multipart = request as http.MultipartRequest;
    expect(multipart.fields, expectedFields);
    expect(
      multipart.files.map((file) => file.field).toSet(),
      expectedFileFields,
    );

    return http.StreamedResponse(
      Stream<List<int>>.value(utf8.encode(_apiObject(_horseDetailJson()))),
      200,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  }
}

class _TempHorseFiles {
  _TempHorseFiles._(this.directory, this.image, this.document);

  final Directory directory;
  final File image;
  final File document;

  static _TempHorseFiles create() {
    final directory = Directory.systemTemp.createTempSync('owner_horse_test_');
    final image = File('${directory.path}/horse.jpg')..writeAsStringSync('jpg');
    final document = File('${directory.path}/horse.pdf')
      ..writeAsStringSync('pdf');
    return _TempHorseFiles._(directory, image, document);
  }

  void dispose() {
    if (directory.existsSync()) {
      directory.deleteSync(recursive: true);
    }
  }
}
