import 'package:flutter_test/flutter_test.dart';
import 'package:horse_racing/src/models/owner_dashboard_data.dart';
import 'package:horse_racing/src/models/owner_horse_item.dart';
import 'package:horse_racing/src/models/owner_tournament_detail.dart';
import 'package:horse_racing/src/models/tournament_list_item.dart';
import 'package:horse_racing/src/models/user_profile.dart';
import 'package:horse_racing/src/repositories/auth_repository.dart';
import 'package:horse_racing/src/repositories/owner_dashboard_repository.dart';
import 'package:horse_racing/src/repositories/owner_tournament_repository.dart';
import 'package:horse_racing/src/services/owner_dashboard_service.dart';
import 'package:horse_racing/src/services/owner_horse_service.dart';
import 'package:horse_racing/src/viewmodels/owner_dashboard_viewmodel.dart';
import 'package:horse_racing/src/viewmodels/owner_profile_viewmodel.dart';
import 'package:horse_racing/src/viewmodels/owner_tournament_detail_viewmodel.dart';
import 'package:horse_racing/src/viewmodels/owner_tournaments_viewmodel.dart';

void main() {
  test(
    'OwnerDashboardViewModel exposes error instead of sample data',
    () async {
      final viewModel = OwnerDashboardViewModel(
        repository: _FailingOwnerDashboardRepository(),
      );

      await viewModel.loadDashboard();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.data, isNull);
      expect(viewModel.errorMessage, 'Không thể tải dữ liệu tổng quan.');
    },
  );

  test(
    'OwnerProfileViewModel exposes error instead of fake owner data',
    () async {
      final viewModel = OwnerProfileViewModel(
        authRepository: _FailingAuthRepository(),
      );

      await viewModel.loadData();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.data, isNull);
      expect(viewModel.errorMessage, 'Không thể tải hồ sơ chủ ngựa.');
    },
  );
  test(
    'OwnerDashboardRepository maps API data without sample fallback',
    () async {
      final repository = OwnerDashboardRepository(
        dashboardService: _FakeOwnerDashboardService(
          dashboard: {
            'upcoming': [
              {
                'id': 9,
                'title': 'Morning Sprint',
                'at': '2026-07-15T09:00:00',
                'status': 'OPEN_REGISTRATION',
                'metadata': {'location': 'Track A'},
              },
            ],
          },
          tournaments: [
            _tournament('1', 'Completed Cup', 'COMPLETED'),
            _tournament('2', 'Open Cup', 'OPEN_REGISTRATION'),
            _tournament('3', 'Ongoing Cup', 'ONGOING'),
          ],
        ),
        horseService: _FakeOwnerHorseService(
          List.generate(
            7,
            (index) => OwnerHorseItem(
              id: '$index',
              name: 'Horse $index',
              breed: 'Breed $index',
              imageUrl: '',
              statusCode: 'APPROVED',
              statusLabel: 'Approved',
            ),
          ),
        ),
        authRepository: _FakeAuthRepository(
          const UserProfile(avatarUrl: 'https://example.test/avatar.jpg'),
        ),
      );

      final data = await repository.fetchDashboard();

      expect(data.hero?.id, '2');
      expect(data.hero?.title, 'Open Cup');
      expect(data.featuredHorses, hasLength(6));
      expect(data.featuredHorses.first.name, 'Horse 0');
      expect(data.upcomingRaces, hasLength(1));
      expect(data.upcomingRaces.single.title, 'Morning Sprint');
      expect(data.profileImageUrl, 'https://example.test/avatar.jpg');
    },
  );

  test('OwnerDashboardRepository keeps empty API data empty', () async {
    final repository = OwnerDashboardRepository(
      dashboardService: _FakeOwnerDashboardService(
        dashboard: {'upcoming': []},
        tournaments: const [],
      ),
      horseService: _FakeOwnerHorseService(const []),
      authRepository: _FailingAuthRepository(),
    );

    final data = await repository.fetchDashboard();

    expect(data.hero, isNull);
    expect(data.featuredHorses, isEmpty);
    expect(data.upcomingRaces, isEmpty);
    expect(data.profileImageUrl, isNull);
  });

  test('OwnerTournamentsViewModel filters statuses for owner tabs', () async {
    final viewModel = OwnerTournamentsViewModel(
      repository: _FakeOwnerTournamentRepository([
        _tournament('1', 'Scheduled', 'SCHEDULED'),
        _tournament('2', 'Open', 'OPEN_REGISTRATION'),
        _tournament('3', 'Ongoing', 'ONGOING'),
        _tournament('4', 'Completed', 'COMPLETED'),
        _tournament('5', 'Cancelled', 'CANCELLED'),
      ]),
      authRepository: _FailingAuthRepository(),
    );

    await viewModel.loadTournaments();

    expect(viewModel.tournaments.map((item) => item.id), [
      '1',
      '2',
      '3',
      '4',
      '5',
    ]);

    viewModel.selectFilter(OwnerTournamentFilter.upcoming);
    expect(viewModel.tournaments.map((item) => item.id), ['1', '2']);

    viewModel.selectFilter(OwnerTournamentFilter.ongoing);
    expect(viewModel.tournaments.map((item) => item.id), ['3']);

    viewModel.selectFilter(OwnerTournamentFilter.completed);
    expect(viewModel.tournaments.map((item) => item.id), ['4', '5']);
  });

  test('OwnerTournamentDetailViewModel exposes detail error state', () async {
    final viewModel = OwnerTournamentDetailViewModel(
      tournamentId: '42',
      repository: _FailingOwnerTournamentRepository(),
    );

    await viewModel.loadDetail();

    expect(viewModel.isLoading, isFalse);
    expect(viewModel.detail, isNull);
    expect(viewModel.errorMessage, isNotNull);
  });
}

class _FailingOwnerDashboardRepository extends OwnerDashboardRepository {
  @override
  Future<OwnerDashboardData> fetchDashboard() async {
    throw Exception('dashboard unavailable');
  }
}

class _FailingAuthRepository extends AuthRepository {
  @override
  Future<UserProfile> refreshCurrentUser() async {
    throw Exception('profile unavailable');
  }
}

class _FakeAuthRepository extends AuthRepository {
  _FakeAuthRepository(this.user);

  final UserProfile user;

  @override
  Future<UserProfile> refreshCurrentUser() async => user;
}

class _FakeOwnerDashboardService extends OwnerDashboardService {
  _FakeOwnerDashboardService({
    required this.dashboard,
    required this.tournaments,
  });

  final Map<String, dynamic> dashboard;
  final List<TournamentListItem> tournaments;

  @override
  Future<Map<String, dynamic>> getOwnerDashboard() async => dashboard;

  @override
  Future<List<TournamentListItem>> getTournaments() async => tournaments;
}

class _FakeOwnerHorseService extends OwnerHorseService {
  _FakeOwnerHorseService(this.horses);

  final List<OwnerHorseItem> horses;

  @override
  Future<List<OwnerHorseItem>> getOwnerHorses() async => horses;
}

class _FakeOwnerTournamentRepository extends OwnerTournamentRepository {
  _FakeOwnerTournamentRepository(this.items);

  final List<TournamentListItem> items;

  @override
  Future<List<TournamentListItem>> fetchTournaments() async => items;
}

class _FailingOwnerTournamentRepository extends OwnerTournamentRepository {
  @override
  Future<OwnerTournamentDetail> fetchTournamentDetail(String id) async {
    throw Exception('detail unavailable');
  }
}

TournamentListItem _tournament(String id, String title, String status) {
  return TournamentListItem(
    id: id,
    title: title,
    imageUrl: '',
    location: 'Track',
    startLabel: 'Start',
    registrationLabel: 'Registration',
    racesLabel: '0 races',
    status: status,
    startAt: DateTime(2026, 7, int.parse(id)),
  );
}
