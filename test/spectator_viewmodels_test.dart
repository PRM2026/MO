import 'package:flutter_test/flutter_test.dart';
import 'package:horse_racing/src/models/jockey_race_result_response.dart';
import 'package:horse_racing/src/models/owner_tournament_detail.dart';
import 'package:horse_racing/src/models/tournament_list_item.dart';
import 'package:horse_racing/src/models/user_profile.dart';
import 'package:horse_racing/src/repositories/spectator_repository.dart';
import 'package:horse_racing/src/services/spectator_api_service.dart';
import 'package:horse_racing/src/viewmodels/spectator_home_viewmodel.dart';
import 'package:horse_racing/src/viewmodels/spectator_profile_viewmodel.dart';
import 'package:horse_racing/src/viewmodels/spectator_race_detail_viewmodel.dart';
import 'package:horse_racing/src/viewmodels/spectator_race_results_viewmodel.dart';
import 'package:horse_racing/src/viewmodels/spectator_races_viewmodel.dart';
import 'package:horse_racing/src/viewmodels/spectator_results_viewmodel.dart';

void main() {
  group('Spectator ViewModels', () {
    test('home load maps API data and retry calls repository again', () async {
      final repository = _FakeSpectatorRepository(
        tournaments: [_tournament()],
        details: {'12': _detail()},
        user: const UserProfile(fullName: 'Spectator One', role: 'SPECTATOR'),
      );
      final viewModel = SpectatorHomeViewModel(repository: repository);

      await viewModel.load();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.data?.featuredEvent?.id, '12');
      expect(viewModel.data?.profile?.displayName, 'Spectator One');
      expect(viewModel.data?.upcomingRaces, hasLength(1));
      expect(repository.tournamentCalls, 1);

      await viewModel.retry();

      expect(repository.tournamentCalls, 2);
    });

    test('home keeps empty API data empty', () async {
      final viewModel = SpectatorHomeViewModel(
        repository: _FakeSpectatorRepository(tournaments: const []),
      );

      await viewModel.load();

      expect(viewModel.errorMessage, isNull);
      expect(viewModel.profileErrorMessage, contains('No user'));
      expect(viewModel.data?.isEmpty, isTrue);
    });

    test('home exposes API error without mock fallback', () async {
      final viewModel = SpectatorHomeViewModel(
        repository: _FakeSpectatorRepository(error: 'BE down'),
      );

      await viewModel.load();

      expect(viewModel.data, isNull);
      expect(viewModel.errorMessage, contains('BE down'));
    });

    test('races load filters upcoming finished and date', () async {
      final viewModel = SpectatorRacesViewModel(
        repository: _FakeSpectatorRepository(
          tournaments: [_tournament()],
          details: {'12': _detail(includeFinished: true)},
        ),
      );

      await viewModel.load();

      expect(viewModel.allRaces, hasLength(2));
      expect(viewModel.races, hasLength(1));
      expect(viewModel.races.single.id, '5');

      viewModel.selectFilter(SpectatorRaceListFilter.finished);
      expect(viewModel.races, hasLength(1));
      expect(viewModel.races.single.id, '6');

      viewModel.selectDate(DateTime(2026, 7, 15));
      expect(viewModel.races, hasLength(1));
      expect(viewModel.races.single.id, '5');
    });

    test('race detail load maps race and results', () async {
      final viewModel = SpectatorRaceDetailViewModel(
        raceId: '5',
        tournamentId: '12',
        repository: _FakeSpectatorRepository(
          details: {'12': _detail()},
          results: {
            '5': [_result()],
          },
        ),
      );

      await viewModel.load();

      expect(viewModel.errorMessage, isNull);
      expect(viewModel.data?.race.id, '5');
      expect(viewModel.data?.hasResults, isTrue);
      expect(viewModel.data?.results.single.horseName, 'Night Wind');
    });

    test('results load keeps empty results empty', () async {
      final viewModel = SpectatorResultsViewModel(
        repository: _FakeSpectatorRepository(
          tournaments: [_tournament()],
          details: {'12': _detail(includeFinished: true)},
          results: const {'6': []},
        ),
      );

      await viewModel.load();

      expect(viewModel.errorMessage, isNull);
      expect(viewModel.groups, isEmpty);
    });

    test('race results load maps leaderboard group', () async {
      final viewModel = SpectatorRaceResultsViewModel(
        raceId: '5',
        repository: _FakeSpectatorRepository(
          results: {
            '5': [_result()],
          },
        ),
      );

      await viewModel.load();

      expect(viewModel.errorMessage, isNull);
      expect(viewModel.data?.raceId, '5');
      expect(viewModel.data?.finishers.single.rank, 1);
    });

    test('profile load maps user and exposes error', () async {
      final success = SpectatorProfileViewModel(
        repository: _FakeSpectatorRepository(
          user: const UserProfile(
            username: 'spectator01',
            fullName: 'Spectator One',
            role: 'SPECTATOR',
          ),
        ),
      );

      await success.load();

      expect(success.data?.displayName, 'Spectator One');
      expect(success.errorMessage, isNull);

      final failure = SpectatorProfileViewModel(
        repository: _FakeSpectatorRepository(error: 'Unauthorized'),
      );

      await failure.load();

      expect(failure.data, isNull);
      expect(failure.errorMessage, contains('Unauthorized'));
    });
  });
}

class _FakeSpectatorRepository extends SpectatorRepository {
  _FakeSpectatorRepository({
    this.tournaments = const [],
    this.details = const {},
    this.results = const {},
    this.user,
    this.error,
  }) : super();

  final List<TournamentListItem> tournaments;
  final Map<String, OwnerTournamentDetail> details;
  final Map<String, List<JockeyRaceResultResponse>> results;
  final UserProfile? user;
  final String? error;
  int tournamentCalls = 0;

  void _throwIfNeeded() {
    if (error != null) throw SpectatorApiException(error!);
  }

  @override
  Future<List<TournamentListItem>> fetchTournaments() async {
    _throwIfNeeded();
    tournamentCalls++;
    return tournaments;
  }

  @override
  Future<OwnerTournamentDetail> fetchTournamentDetail(String id) async {
    _throwIfNeeded();
    final detail = details[id];
    if (detail == null) throw SpectatorApiException('Missing detail $id');
    return detail;
  }

  @override
  Future<List<JockeyRaceResultResponse>> fetchRaceResults(String raceId) async {
    _throwIfNeeded();
    return results[raceId] ?? const [];
  }

  @override
  Future<UserProfile> fetchCurrentUser() async {
    _throwIfNeeded();
    final current = user;
    if (current == null) throw const SpectatorApiException('No user');
    return current;
  }
}

TournamentListItem _tournament() {
  return TournamentListItem.fromJson(const {
    'id': 12,
    'name': 'Summer Cup',
    'provinceName': 'Phu Tho',
    'bannerUrl': '/uploads/tournaments/12.jpg',
    'startAt': '2026-07-15T09:00:00',
    'status': 'OPEN_REGISTRATION',
  });
}

OwnerTournamentDetail _detail({bool includeFinished = false}) {
  return OwnerTournamentDetail.fromJson({
    'id': 12,
    'name': 'Summer Cup',
    'description': 'National race',
    'location': 'Phu Tho',
    'bannerUrl': '/uploads/tournaments/12.jpg',
    'status': 'OPEN_REGISTRATION',
    'races': [
      {
        'id': 5,
        'name': 'Qualifier',
        'distance': '1200m',
        'venueName': 'Track A',
        'scheduledStartAt': '2026-07-15T09:00:00',
        'participantCount': 4,
        'maxParticipants': 12,
        'entryFee': 500000,
        'status': 'SCHEDULED',
      },
      if (includeFinished)
        {
          'id': 6,
          'name': 'Final',
          'distance': '1400m',
          'venueName': 'Track A',
          'scheduledStartAt': '2026-07-16T09:00:00',
          'participantCount': 4,
          'maxParticipants': 12,
          'entryFee': 500000,
          'status': 'RESULT_CONFIRMED',
        },
    ],
  });
}

JockeyRaceResultResponse _result() {
  return JockeyRaceResultResponse.fromJson(const {
    'id': 31,
    'raceId': 5,
    'participantId': 22,
    'ownerId': 4,
    'ownerUsername': 'owner01',
    'horseId': 8,
    'horseName': 'Night Wind',
    'jockeyId': 9,
    'jockeyUsername': 'jockey01',
    'rank': 1,
    'finishTimeMillis': 68123,
    'status': 'FINISHED',
    'jockeyChallengePoints': 10,
    'jockeyPrizeAmount': 500000,
  });
}
