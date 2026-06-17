import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:horse_racing/src/models/auth_session.dart';
import 'package:horse_racing/src/models/jockey_dashboard_data.dart';
import 'package:horse_racing/src/models/jockey_dashboard_response.dart';
import 'package:horse_racing/src/models/jockey_invitation_response.dart';
import 'package:horse_racing/src/models/jockey_performance_response.dart';
import 'package:horse_racing/src/models/user_profile.dart';
import 'package:horse_racing/src/repositories/auth_repository.dart';
import 'package:horse_racing/src/repositories/jockey_dashboard_repository.dart';
import 'package:horse_racing/src/services/api_exception.dart';
import 'package:horse_racing/src/services/auth_storage.dart';
import 'package:horse_racing/src/services/jockey_dashboard_service.dart';
import 'package:horse_racing/src/services/jockey_invitation_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('JockeyDashboardService', () {
    test('calls jockey dashboard API with bearer token', () async {
      final storage = await _storageWithToken('jockey-token');
      final service = JockeyDashboardService(
        baseUrl: 'http://example.test',
        storage: storage,
        client: MockClient((request) async {
          expect(request.method, 'GET');
          expect(
            request.url.toString(),
            'http://example.test/jockey/dashboard',
          );
          expect(request.headers['Authorization'], 'Bearer jockey-token');

          return _jsonResponse(_dashboardJson());
        }),
      );

      final dashboard = await service.getDashboard();

      expect(dashboard.role, 'JOCKEY');
      expect(dashboard.account['fullName'], 'Minh Nguyen');
      expect(dashboard.pendingInvitationCount, 2);
      expect(dashboard.upcoming.single.title, 'Spring Cup');
      expect(dashboard.quickLinks.length, 3);
    });

    test('throws ApiException when backend returns success false', () async {
      final storage = await _storageWithToken('jockey-token');
      final service = JockeyDashboardService(
        baseUrl: 'http://example.test',
        storage: storage,
        client: MockClient(
          (_) async => _jsonResponse({
            'success': false,
            'message': 'Forbidden',
            'data': null,
          }, statusCode: 403),
        ),
      );

      expect(service.getDashboard, throwsA(isA<ApiException>()));
    });

    test('throws ApiException for non json response', () async {
      final storage = await _storageWithToken('jockey-token');
      final service = JockeyDashboardService(
        baseUrl: 'http://example.test',
        storage: storage,
        client: MockClient((_) async => http.Response('not-json', 200)),
      );

      expect(service.getDashboard, throwsA(isA<ApiException>()));
    });

    test('calls jockey performance API and parses fields', () async {
      final storage = await _storageWithToken('jockey-token');
      final service = JockeyDashboardService(
        baseUrl: 'http://example.test',
        storage: storage,
        client: MockClient((request) async {
          expect(request.method, 'GET');
          expect(
            request.url.toString(),
            'http://example.test/jockey/performance',
          );
          expect(request.headers['Authorization'], 'Bearer jockey-token');

          return _jsonResponse(_performanceJson());
        }),
      );

      final performance = await service.getPerformance();

      expect(performance.raceCount, 12);
      expect(performance.completedRaceCount, 9);
      expect(performance.firstPlaces, 4);
      expect(performance.totalJockeyPayout, 15000000);
      expect(performance.recentRaces.single.name, 'Autumn Sprint');
    });

    test('maps null performance fields to zero state', () {
      final performance = JockeyPerformanceResponse.fromJson(const {});

      expect(performance.raceCount, 0);
      expect(performance.completedRaceCount, 0);
      expect(performance.firstPlaces, 0);
      expect(performance.totalJockeyPayout, 0);
      expect(performance.recentRaces, isEmpty);
    });

    test(
      'throws ApiException when performance API returns success false',
      () async {
        final storage = await _storageWithToken('jockey-token');
        final service = JockeyDashboardService(
          baseUrl: 'http://example.test',
          storage: storage,
          client: MockClient(
            (_) async => _jsonResponse({
              'success': false,
              'message': 'Performance failed',
              'data': null,
            }, statusCode: 500),
          ),
        );

        expect(service.getPerformance, throwsA(isA<ApiException>()));
      },
    );
  });

  group('JockeyDashboardData mapping', () {
    test('maps account summary upcoming and quick links', () {
      final response = JockeyDashboardResponse.fromJson(
        _dashboardJson()['data'],
      );

      final data = JockeyDashboardData.fromApi(
        dashboard: response,
        performance: JockeyPerformanceResponse.fromJson(
          _performanceJson()['data'],
        ),
        pendingInvitationCount: response.pendingInvitationCount!,
        profileImageUrl: 'http://image.test/avatar.png',
      );

      expect(data.jockeyName, 'Jockey Minh Nguyen');
      expect(data.profileImageUrl, 'http://image.test/avatar.png');
      expect(data.stats.map((stat) => stat.value), [
        '12',
        '9',
        '4/2/1',
        '15.000.000 đ',
        '7.500.000 đ',
        '2',
      ]);
      expect(data.upcomingRaces.single.title, 'Spring Cup');
      expect(data.recentResults.single.eventName, 'Autumn Sprint');
      expect(data.quickLinks.map((link) => link.label), [
        'Invitations',
        'My Races',
      ]);
    });
  });

  group('JockeyDashboardRepository', () {
    test(
      'uses pending count from summary before invitations fallback',
      () async {
        final repository = JockeyDashboardRepository(
          dashboardService: _FakeDashboardService(
            dashboard: JockeyDashboardResponse.fromJson(
              _dashboardJson()['data'],
            ),
            performance: JockeyPerformanceResponse.fromJson(
              _performanceJson()['data'],
            ),
          ),
          invitationService: _FakeInvitationService(
            invitations: const [
              JockeyInvitationResponse(status: 'PENDING'),
              JockeyInvitationResponse(status: 'PENDING'),
              JockeyInvitationResponse(status: 'PENDING'),
            ],
          ),
          authRepository: _FakeAuthRepository(
            avatarUrl: 'http://avatar.test/a.png',
          ),
        );

        final data = await repository.fetchDashboard();

        expect(data.pendingInvitationCount, 2);
        expect(data.profileImageUrl, 'http://avatar.test/a.png');
      },
    );

    test(
      'falls back to invitations API when summary has no pending count',
      () async {
        final raw = _dashboardJson()['data'] as Map<String, dynamic>;
        final summary = Map<String, dynamic>.from(
          raw['businessSummary'] as Map<String, dynamic>,
        )..remove('invitationsByStatus');

        final repository = JockeyDashboardRepository(
          dashboardService: _FakeDashboardService(
            dashboard: JockeyDashboardResponse.fromJson({
              ...raw,
              'businessSummary': summary,
            }),
            performance: JockeyPerformanceResponse.fromJson(
              _performanceJson()['data'],
            ),
          ),
          invitationService: _FakeInvitationService(
            invitations: const [
              JockeyInvitationResponse(status: 'PENDING'),
              JockeyInvitationResponse(status: 'ACCEPTED'),
            ],
          ),
          authRepository: _ThrowingAuthRepository(),
        );

        final data = await repository.fetchDashboard();

        expect(data.pendingInvitationCount, 1);
        expect(data.profileImageUrl, isNull);
        expect(data.jockeyName, 'Jockey Minh Nguyen');
      },
    );

    test('uses performance API for KPI instead of dashboard summary', () async {
      final raw = _dashboardJson()['data'] as Map<String, dynamic>;
      final repository = JockeyDashboardRepository(
        dashboardService: _FakeDashboardService(
          dashboard: JockeyDashboardResponse.fromJson({
            ...raw,
            'businessSummary': {
              ...(raw['businessSummary'] as Map<String, dynamic>),
              'raceCount': 99,
              'completedRaceCount': 88,
              'firstPlaces': 77,
            },
          }),
          performance: JockeyPerformanceResponse.fromJson(
            _performanceJson()['data'],
          ),
        ),
        invitationService: _FakeInvitationService(invitations: const []),
        authRepository: _ThrowingAuthRepository(),
      );

      final data = await repository.fetchDashboard();

      expect(data.stats.take(3).map((stat) => stat.value), [
        '12',
        '9',
        '4/2/1',
      ]);
      expect(data.recentResults.single.eventName, 'Autumn Sprint');
    });
  });
}

Map<String, dynamic> _dashboardJson() {
  return {
    'success': true,
    'message': 'Success',
    'data': {
      'role': 'JOCKEY',
      'account': {
        'id': 5,
        'username': 'minh_jockey',
        'fullName': 'Minh Nguyen',
      },
      'businessSummary': {
        'invitationsByStatus': {'PENDING': 2, 'ACCEPTED': 4},
        'raceCount': 8,
        'completedRaceCount': 6,
        'firstPlaces': 3,
      },
      'alerts': [
        {
          'type': 'JOCKEY_INVITATION_PENDING',
          'title': 'New invitations waiting for response',
          'status': '2',
        },
      ],
      'upcoming': [
        {
          'type': 'RACE',
          'id': 10,
          'title': 'Spring Cup',
          'status': 'SCHEDULED',
          'at': '2026-06-18T09:30:00',
        },
      ],
      'quickLinks': [
        {'label': 'Invitations', 'route': '/invitations', 'enabled': true},
        {'label': 'My Races', 'route': '/my-races', 'enabled': true},
        {'label': 'Wallet', 'route': '/wallet', 'enabled': false},
      ],
    },
  };
}

Map<String, dynamic> _performanceJson() {
  return {
    'success': true,
    'message': 'Success',
    'data': {
      'jockeyId': 5,
      'raceCount': 12,
      'completedRaceCount': 9,
      'firstPlaces': 4,
      'secondPlaces': 2,
      'thirdPlaces': 1,
      'totalJockeyPayout': 15000000,
      'totalPrizePayout': 7500000,
      'recentRaces': [
        {
          'id': 22,
          'name': 'Autumn Sprint',
          'distance': '1600m',
          'venueName': 'Saigon Track',
          'provinceName': 'HCMC',
          'scheduledStartAt': '2026-06-16T10:00:00',
          'status': 'COMPLETED',
          'participantCount': 8,
        },
      ],
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

class _FakeDashboardService extends JockeyDashboardService {
  _FakeDashboardService({required this.dashboard, required this.performance});

  final JockeyDashboardResponse dashboard;
  final JockeyPerformanceResponse performance;

  @override
  Future<JockeyDashboardResponse> getDashboard() async => dashboard;

  @override
  Future<JockeyPerformanceResponse> getPerformance() async => performance;
}

class _FakeInvitationService extends JockeyInvitationService {
  _FakeInvitationService({required this.invitations});

  final List<JockeyInvitationResponse> invitations;

  @override
  Future<List<JockeyInvitationResponse>> getJockeyInvitations() async {
    return invitations;
  }
}

class _FakeAuthRepository extends AuthRepository {
  _FakeAuthRepository({required this.avatarUrl});

  final String avatarUrl;

  @override
  Future<UserProfile> refreshCurrentUser() async {
    return UserProfile(avatarUrl: avatarUrl);
  }
}

class _ThrowingAuthRepository extends AuthRepository {
  @override
  Future<UserProfile> refreshCurrentUser() {
    throw Exception('auth failed');
  }
}
