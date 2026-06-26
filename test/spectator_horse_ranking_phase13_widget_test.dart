import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horse_racing/src/models/jockey_race_result_response.dart';
import 'package:horse_racing/src/models/owner_tournament_detail.dart';
import 'package:horse_racing/src/models/spectator_models.dart';
import 'package:horse_racing/src/models/tournament_list_item.dart';
import 'package:horse_racing/src/models/user_profile.dart';
import 'package:horse_racing/src/repositories/spectator_repository.dart';
import 'package:horse_racing/src/services/spectator_api_service.dart';
import 'package:horse_racing/src/viewmodels/spectator_home_viewmodel.dart';
import 'package:horse_racing/src/viewmodels/spectator_horse_ranking_viewmodel.dart';
import 'package:horse_racing/src/views/spectator/spectator_home_screen.dart';
import 'package:horse_racing/src/views/spectator/spectator_horse_ranking_screen.dart';

void main() {
  testWidgets('horse ranking screen renders public API horses sorted by rank', (
    tester,
  ) async {
    final viewModel = SpectatorHorseRankingViewModel(
      repository: _FakeSpectatorRepository(
        horses: [
          _horse(id: '9', name: 'Silver Arrow', rank: 2, winRate: '65%'),
          _horse(id: '8', name: 'Night Wind', rank: 1, winRate: '80%'),
        ],
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: SpectatorHorseRankingScreen(viewModel: viewModel)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bang xep hang ngua'), findsOneWidget);
    expect(find.text('Night Wind'), findsOneWidget);
    expect(find.text('Silver Arrow'), findsOneWidget);
    expect(find.text('Win rate: 80%'), findsOneWidget);

    final firstHorse = tester.getTopLeft(find.text('Night Wind')).dy;
    final secondHorse = tester.getTopLeft(find.text('Silver Arrow')).dy;
    expect(firstHorse, lessThan(secondHorse));
  });

  testWidgets('horse ranking screen shows empty state', (tester) async {
    final viewModel = SpectatorHorseRankingViewModel(
      repository: _FakeSpectatorRepository(horses: const []),
    );

    await tester.pumpWidget(
      MaterialApp(home: SpectatorHorseRankingScreen(viewModel: viewModel)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Chua co bang xep hang ngua.'), findsOneWidget);
  });

  testWidgets('horse ranking screen shows error and retries', (tester) async {
    final repository = _FakeSpectatorRepository(
      failuresBeforeSuccess: 1,
      horses: [_horse(id: '8', name: 'Night Wind', rank: 1)],
    );
    final viewModel = SpectatorHorseRankingViewModel(repository: repository);

    await tester.pumpWidget(
      MaterialApp(home: SpectatorHorseRankingScreen(viewModel: viewModel)),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Temporary failure'), findsOneWidget);
    expect(repository.horseCalls, 1);

    await tester.tap(find.text('Thu lai'));
    await tester.pumpAndSettle();

    expect(find.text('Night Wind'), findsOneWidget);
    expect(repository.horseCalls, 2);
  });

  testWidgets('home horse quick action opens horse ranking callback', (
    tester,
  ) async {
    var openedHorses = false;
    final viewModel = _HomeViewModel(data: const SpectatorHomeData());

    await tester.pumpWidget(
      MaterialApp(
        home: SpectatorHomeScreen(
          viewModel: viewModel,
          onHorsesTap: () => openedHorses = true,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Danh sach ngua'));
    await tester.pump();

    expect(openedHorses, isTrue);
  });
}

class _FakeSpectatorRepository extends SpectatorRepository {
  _FakeSpectatorRepository({
    this.horses = const [],
    this.failuresBeforeSuccess = 0,
  }) : super();

  final List<SpectatorFeaturedHorse> horses;
  int failuresBeforeSuccess;
  int horseCalls = 0;

  @override
  Future<List<SpectatorFeaturedHorse>> fetchHorseRankings() async {
    horseCalls++;
    if (failuresBeforeSuccess > 0) {
      failuresBeforeSuccess--;
      throw const SpectatorApiException('Temporary failure');
    }
    return horses;
  }

  @override
  Future<List<TournamentListItem>> fetchTournaments() async {
    return const [];
  }

  @override
  Future<OwnerTournamentDetail> fetchTournamentDetail(String id) async {
    throw const SpectatorApiException('Unused');
  }

  @override
  Future<List<JockeyRaceResultResponse>> fetchRaceResults(String raceId) async {
    return const [];
  }

  @override
  Future<UserProfile> fetchCurrentUser() async {
    throw const SpectatorApiException('No user');
  }
}

class _HomeViewModel extends SpectatorHomeViewModel {
  _HomeViewModel({required SpectatorHomeData data}) : _nextData = data;

  final SpectatorHomeData _nextData;

  @override
  Future<void> load() async {
    data = _nextData;
    isLoading = false;
    errorMessage = null;
    profileErrorMessage = null;
    notifyListeners();
  }
}

SpectatorFeaturedHorse _horse({
  required String id,
  required String name,
  required int rank,
  String winRate = '--',
}) {
  return SpectatorFeaturedHorse(
    id: id,
    name: name,
    rider: 'jockey$id',
    rank: rank,
    imageUrl: '/uploads/horses/$id.jpg',
    winRateLabel: winRate,
  );
}
