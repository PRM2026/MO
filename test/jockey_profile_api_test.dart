import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:horse_racing/src/models/auth_session.dart';
import 'package:horse_racing/src/models/jockey_profile_response.dart';
import 'package:horse_racing/src/repositories/jockey_profile_repository.dart';
import 'package:horse_racing/src/services/api_exception.dart';
import 'package:horse_racing/src/services/auth_storage.dart';
import 'package:horse_racing/src/services/jockey_profile_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('JockeyProfileService', () {
    test(
      'calls profile API with bearer token and parses full response',
      () async {
        final storage = await _storageWithToken('jockey-token');
        final service = JockeyProfileService(
          baseUrl: 'http://example.test',
          storage: storage,
          client: MockClient((request) async {
            expect(request.method, 'GET');
            expect(
              request.url.toString(),
              'http://example.test/jockey/profile',
            );
            expect(request.headers['Authorization'], 'Bearer jockey-token');
            return _jsonResponse(_profileEnvelope());
          }),
        );

        final profile = await service.getMyProfile();

        expect(profile.id, 11);
        expect(profile.userId, 5);
        expect(profile.displayName, 'Minh Nguyen');
        expect(profile.statusCode, 'APPROVED');
        expect(profile.performance.totalRaces, 12);
        expect(profile.performance.rankCounts['1'], 4);
        expect(profile.raceHistory.single.raceName, 'Autumn Sprint');
      },
    );

    test('throws ApiException for success false', () async {
      final storage = await _storageWithToken('jockey-token');
      final service = JockeyProfileService(
        baseUrl: 'http://example.test',
        storage: storage,
        client: MockClient(
          (_) async => _jsonResponse({
            'success': false,
            'message': 'Profile not found',
            'data': null,
          }, statusCode: 404),
        ),
      );

      expect(service.getMyProfile, throwsA(isA<ApiException>()));
    });

    test('throws ApiException for non json response', () async {
      final storage = await _storageWithToken('jockey-token');
      final service = JockeyProfileService(
        baseUrl: 'http://example.test',
        storage: storage,
        client: MockClient((_) async => http.Response('not-json', 200)),
      );

      expect(service.getMyProfile, throwsA(isA<ApiException>()));
    });
  });

  group('JockeyProfileResponse', () {
    test('maps missing nested fields to zero and empty state', () {
      final profile = JockeyProfileResponse.fromJson(const {});

      expect(profile.id, 0);
      expect(profile.userId, 0);
      expect(profile.performance.totalRaces, 0);
      expect(profile.performance.wins, 0);
      expect(profile.performance.rankCounts, isEmpty);
      expect(profile.raceHistory, isEmpty);
      expect(profile.displayName, 'Jockey');
    });

    test('shows review reason only for rejected or suspended status', () {
      final rejected = JockeyProfileResponse.fromJson({
        'status': 'REJECTED',
        'reviewReason': 'License document is invalid',
      });
      final pending = JockeyProfileResponse.fromJson({
        'status': 'PENDING',
        'reviewReason': 'Waiting',
      });

      expect(rejected.shouldShowReviewReason, isTrue);
      expect(pending.shouldShowReviewReason, isFalse);
    });
  });

  test('repository returns API profile without sample fallback', () async {
    final repository = JockeyProfileRepository(
      service: _FakeJockeyProfileService(
        profile: JockeyProfileResponse.fromJson(
          _profileEnvelope()['data'] as Map<String, dynamic>,
        ),
      ),
    );

    final profile = await repository.fetchProfile();

    expect(profile.displayName, 'Minh Nguyen');
    expect(profile.licenseNumber, 'JCK-2026-001');
    expect(profile.raceHistory, hasLength(1));
  });
}

Map<String, dynamic> _profileEnvelope() {
  return {
    'success': true,
    'message': 'Success',
    'data': {
      'id': 11,
      'userId': 5,
      'username': 'minh_jockey',
      'fullName': 'Minh Nguyen',
      'licenseNumber': 'JCK-2026-001',
      'experienceYears': 7,
      'heightCm': 168.5,
      'weightKg': 54,
      'bio': 'Professional jockey',
      'awards': 'National Cup 2025',
      'achievements': 'https://example.test/achievement.png',
      'specialties': 'Sprint',
      'avatarUrl': 'https://example.test/avatar.png',
      'licenseDocumentUrl': 'https://example.test/license.pdf',
      'status': 'APPROVED',
      'reviewReason': null,
      'reviewedBy': 1,
      'reviewedAt': '2026-06-15T08:30:00',
      'performance': {
        'totalRaces': 12,
        'wins': 4,
        'winRate': 33.33,
        'rankCounts': {'1': 4, '2': 2, '3': 1},
      },
      'raceHistory': [
        {
          'tournamentId': 3,
          'tournamentName': 'National Cup',
          'raceId': 22,
          'raceName': 'Autumn Sprint',
          'scheduledStartAt': '2026-06-12T10:00:00',
          'horseId': 8,
          'horseName': 'Night Wind',
          'rank': 1,
          'status': 'FINISHED',
          'finishTimeMillis': 73450,
          'finalizedAt': '2026-06-12T12:00:00',
        },
      ],
      'createdAt': '2026-01-01T09:00:00',
      'updatedAt': '2026-06-15T08:30:00',
    },
  };
}

http.Response _jsonResponse(Map<String, dynamic> body, {int statusCode = 200}) {
  return http.Response.bytes(utf8.encode(jsonEncode(body)), statusCode);
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

class _FakeJockeyProfileService extends JockeyProfileService {
  _FakeJockeyProfileService({required this.profile});

  final JockeyProfileResponse profile;

  @override
  Future<JockeyProfileResponse> getMyProfile() async => profile;
}
