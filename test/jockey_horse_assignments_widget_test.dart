import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horse_racing/src/models/jockey_horse_data.dart';
import 'package:horse_racing/src/repositories/jockey_horses_repository.dart';
import 'package:horse_racing/src/viewmodels/jockey_horses_viewmodel.dart';
import 'package:horse_racing/src/views/jockey/jockey_horses_screen.dart';

void main() {
  testWidgets('renders real assignment fields without mock horse stats', (
    tester,
  ) async {
    await tester.pumpWidget(_app(data: _data([_assignment()])));
    await tester.pumpAndSettle();

    expect(find.text('Ngựa được phân công'), findsOneWidget);
    expect(find.text('Night Wind'), findsOneWidget);
    expect(find.text('stable_owner'), findsOneWidget);
    expect(find.text('Autumn Sprint'), findsOneWidget);
    expect(find.text('National Cup'), findsOneWidget);
    expect(find.text('01/07/2026 08:00'), findsOneWidget);
    expect(find.text('500.000 đ'), findsOneWidget);
    expect(find.text('Đã nhận'), findsOneWidget);
    expect(find.text('Đã lên lịch'), findsOneWidget);

    expect(find.text('Thoroughbred'), findsNothing);
    expect(find.textContaining('Speed'), findsNothing);
    expect(find.textContaining('Stamina'), findsNothing);
    expect(find.textContaining('Health'), findsNothing);
  });

  testWidgets('shows accepted-assignment empty state', (tester) async {
    await tester.pumpWidget(
      _app(data: const JockeyHorseAssignmentsData(assignments: [])),
    );
    await tester.pumpAndSettle();

    expect(find.text('Chưa có ngựa nào được phân công.'), findsOneWidget);
  });

  testWidgets('opens race detail when current race was resolved', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        data: _data([_assignment(hasRaceDetail: true)]),
        raceDetailBuilder: (_, id) => Scaffold(body: Text('race-detail-$id')),
        invitationDetailBuilder: (_, id) =>
            Scaffold(body: Text('invitation-detail-$id')),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('horse-assignment-7')));
    await tester.pumpAndSettle();

    expect(find.text('race-detail-31'), findsOneWidget);
    expect(find.text('invitation-detail-7'), findsNothing);
  });

  testWidgets('opens invitation detail when race cannot be resolved', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        data: _data([_assignment(hasRaceDetail: false)]),
        raceDetailBuilder: (_, id) => Scaffold(body: Text('race-detail-$id')),
        invitationDetailBuilder: (_, id) =>
            Scaffold(body: Text('invitation-detail-$id')),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('horse-assignment-7')));
    await tester.pumpAndSettle();

    expect(find.text('invitation-detail-7'), findsOneWidget);
    expect(find.text('race-detail-31'), findsNothing);
  });
}

Widget _app({
  required JockeyHorseAssignmentsData data,
  JockeyAssignmentDestinationBuilder? raceDetailBuilder,
  JockeyAssignmentDestinationBuilder? invitationDetailBuilder,
}) {
  return MaterialApp(
    home: JockeyHorsesScreen(
      viewModel: JockeyHorsesViewModel(
        repository: _AssignmentsRepository(data),
      ),
      raceDetailBuilder: raceDetailBuilder,
      invitationDetailBuilder: invitationDetailBuilder,
    ),
  );
}

class _AssignmentsRepository extends JockeyHorsesRepository {
  _AssignmentsRepository(this.data);

  final JockeyHorseAssignmentsData data;

  @override
  Future<JockeyHorseAssignmentsData> fetchAssignments() async => data;
}

JockeyHorseAssignmentsData _data(List<JockeyHorseAssignmentItem> assignments) {
  return JockeyHorseAssignmentsData(assignments: assignments);
}

JockeyHorseAssignmentItem _assignment({bool hasRaceDetail = true}) {
  return JockeyHorseAssignmentItem(
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
    scheduledStartAt: DateTime.parse('2026-07-01T08:00:00'),
    hasRaceDetail: hasRaceDetail,
  );
}
