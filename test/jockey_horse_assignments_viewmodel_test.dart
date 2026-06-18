import 'package:flutter_test/flutter_test.dart';
import 'package:horse_racing/src/models/jockey_horse_data.dart';
import 'package:horse_racing/src/repositories/jockey_horses_repository.dart';
import 'package:horse_racing/src/viewmodels/jockey_horses_viewmodel.dart';

void main() {
  test('loads assignment data without sample fallback', () async {
    final viewModel = JockeyHorsesViewModel(
      repository: _AssignmentsRepository(_data()),
    );

    await viewModel.loadAssignments();

    expect(viewModel.isLoading, isFalse);
    expect(viewModel.data?.assignments, hasLength(1));
    expect(viewModel.errorMessage, isNull);
  });

  test('supports an empty accepted-assignment state', () async {
    final viewModel = JockeyHorsesViewModel(
      repository: _AssignmentsRepository(
        const JockeyHorseAssignmentsData(assignments: []),
      ),
    );

    await viewModel.loadAssignments();

    expect(viewModel.data?.assignments, isEmpty);
    expect(viewModel.errorMessage, isNull);
  });

  test('retry replaces invitation API error with assignment data', () async {
    final repository = _RetryAssignmentsRepository();
    final viewModel = JockeyHorsesViewModel(repository: repository);

    await viewModel.loadAssignments();
    expect(
      viewModel.errorMessage,
      'Không thể tải danh sách ngựa được phân công.',
    );
    expect(viewModel.data, isNull);

    await viewModel.loadAssignments();
    expect(viewModel.data?.assignments, hasLength(1));
    expect(repository.calls, 2);
  });
}

class _AssignmentsRepository extends JockeyHorsesRepository {
  _AssignmentsRepository(this.data);

  final JockeyHorseAssignmentsData data;

  @override
  Future<JockeyHorseAssignmentsData> fetchAssignments() async => data;
}

class _RetryAssignmentsRepository extends JockeyHorsesRepository {
  int calls = 0;

  @override
  Future<JockeyHorseAssignmentsData> fetchAssignments() async {
    calls++;
    if (calls == 1) throw Exception('invitation API failed');
    return _data();
  }
}

JockeyHorseAssignmentsData _data() {
  return const JockeyHorseAssignmentsData(
    assignments: [
      JockeyHorseAssignmentItem(
        invitationId: '7',
        horseId: 21,
        horseName: 'Night Wind',
        ownerUsername: 'stable_owner',
        raceId: '31',
        raceName: 'Autumn Sprint',
        tournamentId: '41',
        tournamentName: 'National Cup',
        assignmentStatusCode: 'ACCEPTED',
        raceStatusCode: 'SCHEDULED',
        remunerationAmount: 500000,
        hasRaceDetail: true,
      ),
    ],
  );
}
