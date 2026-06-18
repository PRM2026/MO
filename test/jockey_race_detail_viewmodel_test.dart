import 'package:flutter_test/flutter_test.dart';
import 'package:horse_racing/src/models/jockey_race_response.dart';
import 'package:horse_racing/src/repositories/jockey_race_detail_repository.dart';
import 'package:horse_racing/src/viewmodels/jockey_race_detail_viewmodel.dart';

void main() {
  test('loads the requested race from jockey races', () async {
    final viewModel = JockeyRaceDetailViewModel(
      raceId: '22',
      repository: _FakeDetailRepository(race: _race()),
    );

    await viewModel.loadRace();

    expect(viewModel.race?.id, '22');
    expect(viewModel.errorMessage, isNull);
  });

  test('maps a missing race to a not-found state', () async {
    final viewModel = JockeyRaceDetailViewModel(
      raceId: '404',
      repository: _FakeDetailRepository(notFound: true),
    );

    await viewModel.loadRace();

    expect(viewModel.race, isNull);
    expect(
      viewModel.errorMessage,
      'Không tìm thấy cuộc đua này trong lịch của bạn.',
    );
  });

  test('retry replaces an error with race data', () async {
    final repository = _RetryDetailRepository();
    final viewModel = JockeyRaceDetailViewModel(
      raceId: '22',
      repository: repository,
    );

    await viewModel.loadRace();
    expect(viewModel.errorMessage, 'Không thể tải chi tiết cuộc đua.');

    await viewModel.loadRace();
    expect(viewModel.race?.id, '22');
    expect(repository.calls, 2);
  });
}

class _FakeDetailRepository extends JockeyRaceDetailRepository {
  _FakeDetailRepository({this.race, this.notFound = false});

  final JockeyRaceResponse? race;
  final bool notFound;

  @override
  Future<JockeyRaceResponse> fetchRace(String raceId) async {
    if (notFound) throw JockeyRaceNotFoundException(raceId);
    return race!;
  }
}

class _RetryDetailRepository extends JockeyRaceDetailRepository {
  int calls = 0;

  @override
  Future<JockeyRaceResponse> fetchRace(String raceId) async {
    calls++;
    if (calls == 1) throw Exception('offline');
    return _race();
  }
}

JockeyRaceResponse _race() {
  return const JockeyRaceResponse(
    id: '22',
    tournamentId: '7',
    name: 'Autumn Sprint',
    participantCount: 8,
  );
}
