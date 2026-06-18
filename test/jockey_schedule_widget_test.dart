import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horse_racing/src/models/jockey_race_response.dart';
import 'package:horse_racing/src/models/jockey_schedule_data.dart';
import 'package:horse_racing/src/repositories/jockey_schedule_repository.dart';
import 'package:horse_racing/src/viewmodels/jockey_schedule_viewmodel.dart';
import 'package:horse_racing/src/views/jockey/jockey_schedule_screen.dart';

void main() {
  testWidgets('renders calendar schedule from API data without fake actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        repository: _FakeScheduleRepository([
          _race(
            id: '1',
            name: 'Autumn Sprint',
            scheduledStartAt: DateTime.parse('2026-06-18T08:00:00'),
            scheduledEndAt: DateTime.parse('2026-06-18T09:30:00'),
          ),
        ]),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Lịch thi đấu'), findsOneWidget);
    expect(find.text('Autumn Sprint'), findsOneWidget);
    expect(find.text('Saigon Track • HCMC'), findsOneWidget);
    expect(find.text('08:00 - 09:30'), findsWidgets);
    expect(find.text('Đã lên lịch'), findsOneWidget);
    expect(find.text('Chỉ đường'), findsOneWidget);

    expect(find.text('Xác nhận tham gia'), findsNothing);
    expect(find.text('Silver Storm'), findsNothing);
    expect(find.text('Lane 5'), findsNothing);

    expect(find.byKey(const Key('race-details-1')), findsOneWidget);
  });

  testWidgets('list mode shows unscheduled section', (tester) async {
    await tester.pumpWidget(
      _app(
        repository: _FakeScheduleRepository([
          _race(
            id: '1',
            name: 'Scheduled Race',
            scheduledStartAt: DateTime.parse('2026-06-18T08:00:00'),
          ),
          _race(id: '2', name: 'Draft Race', scheduledStartAt: null),
        ]),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Draft Race'), findsNothing);

    await tester.tap(find.text('Danh sách'));
    await tester.pumpAndSettle();

    expect(find.text('Scheduled Race'), findsOneWidget);
    expect(find.text('Chưa lên lịch'), findsWidgets);
    expect(find.text('Draft Race'), findsOneWidget);
  });

  testWidgets('shows API error with retry action', (tester) async {
    final repository = _RetryScheduleRepository();

    await tester.pumpWidget(_app(repository: repository));
    await tester.pumpAndSettle();

    expect(find.text('Không thể tải lịch thi đấu.'), findsOneWidget);
    expect(repository.loadCount, 1);

    await tester.tap(find.text('Thử lại'));
    await tester.pumpAndSettle();

    expect(find.text('Recovered Race'), findsOneWidget);
    expect(repository.loadCount, 2);
  });
}

Widget _app({required JockeyScheduleRepository repository}) {
  return MaterialApp(
    home: JockeyScheduleScreen(
      viewModel: JockeyScheduleViewModel(repository: repository),
    ),
  );
}

class _FakeScheduleRepository extends JockeyScheduleRepository {
  _FakeScheduleRepository(this.races);

  final List<JockeyRaceResponse> races;

  @override
  Future<JockeyScheduleData> fetchSchedule() async {
    return JockeyScheduleData.fromResponses(races);
  }
}

class _RetryScheduleRepository extends JockeyScheduleRepository {
  int loadCount = 0;

  @override
  Future<JockeyScheduleData> fetchSchedule() async {
    loadCount++;
    if (loadCount == 1) throw Exception('Backend unavailable');
    return JockeyScheduleData.fromResponses([
      _race(
        id: '1',
        name: 'Recovered Race',
        scheduledStartAt: DateTime.parse('2026-06-18T08:00:00'),
      ),
    ]);
  }
}

JockeyRaceResponse _race({
  required String id,
  required String name,
  DateTime? scheduledStartAt,
  DateTime? scheduledEndAt,
}) {
  return JockeyRaceResponse(
    id: id,
    tournamentId: '7',
    name: name,
    distance: '1600m',
    venueName: 'Saigon Track',
    venueAddress: 'District 7',
    provinceName: 'HCMC',
    scheduledStartAt: scheduledStartAt,
    scheduledEndAt: scheduledEndAt,
    refereeUsername: 'referee01',
    status: 'SCHEDULED',
    participantCount: 8,
  );
}
