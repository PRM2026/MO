import 'package:flutter_test/flutter_test.dart';
import 'package:horse_racing/src/models/owner_dashboard_data.dart';
import 'package:horse_racing/src/models/owner_horse_item.dart';
import 'package:horse_racing/src/models/owner_profile_data.dart';
import 'package:horse_racing/src/models/owner_tournament_detail.dart';
import 'package:horse_racing/src/models/tournament_list_item.dart';
import 'package:horse_racing/src/models/user_profile.dart';
import 'package:horse_racing/src/repositories/auth_repository.dart';
import 'package:horse_racing/src/repositories/owner_dashboard_repository.dart';
import 'package:horse_racing/src/repositories/owner_horse_repository.dart';
import 'package:horse_racing/src/repositories/owner_tournament_repository.dart';
import 'package:horse_racing/src/services/owner_dashboard_service.dart';
import 'package:horse_racing/src/services/owner_horse_service.dart';
import 'package:horse_racing/src/viewmodels/owner_change_password_viewmodel.dart';
import 'package:horse_racing/src/viewmodels/owner_dashboard_viewmodel.dart';
import 'package:horse_racing/src/viewmodels/owner_horses_viewmodel.dart';
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
  test('OwnerProfileData maps auth user without fake id', () {
    final full = OwnerProfileData.fromUserProfile(
      const UserProfile(
        id: 12,
        username: 'owner12',
        email: 'owner@example.test',
        fullName: 'Owner Name',
        role: 'OWNER',
        avatarUrl: 'https://example.test/avatar.jpg',
      ),
    );
    final missing = OwnerProfileData.fromUserProfile(
      const UserProfile(role: 'OWNER'),
    );

    expect(full.id, 12);
    expect(full.displayId, '12');
    expect(full.fullName, 'Owner Name');
    expect(full.username, 'owner12');
    expect(full.email, 'owner@example.test');
    expect(full.roleLabel, 'Chủ ngựa');
    expect(full.avatarUrl, 'https://example.test/avatar.jpg');
    expect(full.settings.single.title, 'Bảo mật & Mật khẩu');

    expect(missing.id, isNull);
    expect(missing.displayId, isNull);
    expect(missing.fullName, 'Chủ ngựa');
  });

  test('OwnerProfileViewModel maps auth user and logs out', () async {
    final authRepository = _TrackingAuthRepository(
      const UserProfile(
        id: 9,
        fullName: 'Stable Owner',
        email: 'stable@example.test',
        role: 'OWNER',
      ),
    );
    final viewModel = OwnerProfileViewModel(authRepository: authRepository);

    await viewModel.loadData();

    expect(viewModel.isLoading, isFalse);
    expect(viewModel.errorMessage, isNull);
    expect(viewModel.data?.fullName, 'Stable Owner');
    expect(viewModel.data?.displayId, '9');

    expect(await viewModel.logout(), isTrue);
    expect(authRepository.logoutCalls, 1);
    expect(viewModel.isLoggingOut, isFalse);
  });

  test('OwnerHorsesViewModel keeps empty API data empty', () async {
    final viewModel = OwnerHorsesViewModel(
      repository: _FakeOwnerHorseRepository(const []),
      authRepository: _FailingAuthRepository(),
    );

    await viewModel.loadHorses();

    expect(viewModel.isLoading, isFalse);
    expect(viewModel.errorMessage, isNull);
    expect(viewModel.horses, isEmpty);
    expect(viewModel.filteredHorses, isEmpty);
  });

  test('OwnerHorsesViewModel searches and filters loaded API data', () async {
    final viewModel = OwnerHorsesViewModel(
      repository: _FakeOwnerHorseRepository([
        _horse(
          id: '1',
          name: 'Night Wind',
          breed: 'Thoroughbred',
          statusCode: 'APPROVED',
          totalRaces: 8,
          wins: 5,
          winRate: 62,
        ),
        _horse(
          id: '2',
          name: 'Young Star',
          breed: 'Arabian',
          statusCode: 'PENDING',
          totalRaces: 0,
          wins: 0,
          winRate: 0,
        ),
      ]),
      authRepository: _FailingAuthRepository(),
    );

    await viewModel.loadHorses();

    expect(viewModel.filteredHorses.map((horse) => horse.id), ['1', '2']);

    viewModel.updateSearch('night');
    expect(viewModel.filteredHorses.map((horse) => horse.id), ['1']);

    viewModel.updateSearch('');
    viewModel.selectFilter(OwnerHorseFilter.racing);
    expect(viewModel.filteredHorses.map((horse) => horse.id), ['1']);

    viewModel.selectFilter(OwnerHorseFilter.prospect);
    expect(viewModel.filteredHorses.map((horse) => horse.id), ['2']);
  });

  test('OwnerHorsesViewModel exposes API errors', () async {
    final viewModel = OwnerHorsesViewModel(
      repository: _FailingOwnerHorseRepository(),
      authRepository: _FailingAuthRepository(),
    );

    await viewModel.loadHorses();

    expect(viewModel.isLoading, isFalse);
    expect(viewModel.horses, isEmpty);
    expect(viewModel.errorMessage, isNotNull);
  });

  test('OwnerChangePasswordViewModel validates and submits', () async {
    final authRepository = _PasswordAuthRepository();
    final viewModel = OwnerChangePasswordViewModel(
      authRepository: authRepository,
    );

    expect(
      viewModel.validate(
        currentPassword: '',
        newPassword: 'Password1',
        confirmPassword: 'Password1',
      ),
      'Vui lòng nhập mật khẩu hiện tại.',
    );

    final success = await viewModel.submit(
      currentPassword: 'OldPassword1',
      newPassword: 'NewPassword1',
      confirmPassword: 'NewPassword1',
    );

    expect(success, isTrue);
    expect(authRepository.currentPassword, 'OldPassword1');
    expect(authRepository.newPassword, 'NewPassword1');
    expect(viewModel.isSubmitting, isFalse);
  });

  test('OwnerChangePasswordViewModel exposes backend errors', () async {
    final viewModel = OwnerChangePasswordViewModel(
      authRepository: _PasswordAuthRepository(
        error: Exception('Wrong password'),
      ),
    );

    final success = await viewModel.submit(
      currentPassword: 'OldPassword1',
      newPassword: 'NewPassword1',
      confirmPassword: 'NewPassword1',
    );

    expect(success, isFalse);
    expect(viewModel.errorMessage, contains('Wrong password'));
    expect(viewModel.isSubmitting, isFalse);
  });

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
              documentUrl: '',
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

class _TrackingAuthRepository extends AuthRepository {
  _TrackingAuthRepository(this.user);

  final UserProfile user;
  int logoutCalls = 0;

  @override
  Future<UserProfile> refreshCurrentUser() async => user;

  @override
  Future<void> logout() async {
    logoutCalls++;
  }
}

class _PasswordAuthRepository extends AuthRepository {
  _PasswordAuthRepository({this.error});

  final Object? error;
  String? currentPassword;
  String? newPassword;

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final error = this.error;
    if (error != null) throw error;
    this.currentPassword = currentPassword;
    this.newPassword = newPassword;
  }
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

class _FakeOwnerHorseRepository extends OwnerHorseRepository {
  _FakeOwnerHorseRepository(this.items);

  final List<OwnerHorseItem> items;

  @override
  Future<List<OwnerHorseItem>> fetchHorses() async => items;
}

class _FailingOwnerHorseRepository extends OwnerHorseRepository {
  @override
  Future<List<OwnerHorseItem>> fetchHorses() async {
    throw Exception('horses unavailable');
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

OwnerHorseItem _horse({
  required String id,
  required String name,
  required String breed,
  required String statusCode,
  required int totalRaces,
  required int wins,
  required double winRate,
}) {
  return OwnerHorseItem(
    id: id,
    name: name,
    breed: breed,
    imageUrl: '',
    documentUrl: '',
    statusCode: statusCode,
    statusLabel: statusCode,
    performance: OwnerHorsePerformance(
      totalRaces: totalRaces,
      wins: wins,
      winRate: winRate,
    ),
  );
}
