import 'package:flutter_test/flutter_test.dart';
import 'package:horse_racing/src/models/jockey_race_response.dart';
import 'package:horse_racing/src/models/jockey_schedule_data.dart';
import 'package:horse_racing/src/repositories/jockey_schedule_repository.dart';
import 'package:horse_racing/src/viewmodels/jockey_schedule_viewmodel.dart';

void main() {
  group('JockeyScheduleData mapping', () {
    test('maps only API-backed fields and explicit fallbacks', () {
      final data = JockeyScheduleData.fromResponses([
        _race(
          name: null,
          distance: null,
          venueName: null,
          provinceName: null,
          refereeUsername: null,
          scheduledStartAt: null,
          scheduledEndAt: null,
          participantCount: 0,
          status: null,
        ),
      ]);

      final race = data.races.single;

      expect(race.eventName, 'Cuộc đua chưa đặt tên');
      expect(race.distanceLabel, 'Chưa có cự ly');
      expect(race.venue, 'Chưa có địa điểm');
      expect(race.refereeLabel, 'Chưa phân công');
      expect(race.participantLabel, 'Chưa có người tham gia');
      expect(race.timeLabel, 'Chưa lên lịch');
      expect(race.statusLabel, 'Chưa rõ trạng thái');
      expect(race.isUnscheduled, isTrue);
    });

    test(
      'creates date selector from scheduled races and groups unscheduled',
      () {
        final data = JockeyScheduleData.fromResponses([
          _race(
            id: '1',
            scheduledStartAt: DateTime.parse('2026-06-18T08:00:00'),
          ),
          _race(
            id: '2',
            scheduledStartAt: DateTime.parse('2026-06-18T12:00:00'),
          ),
          _race(id: '3', scheduledStartAt: null),
        ]);

        expect(data.dates, hasLength(1));
        expect(data.dates.single.dateKey, '2026-06-18');
        expect(data.dates.single.isSelected, isTrue);
        expect(data.unscheduledRaces.single.id, '3');
      },
    );
  });

  group('JockeyScheduleViewModel', () {
    test(
      'defaults to first scheduled date and filters calendar races',
      () async {
        final viewModel = JockeyScheduleViewModel(
          repository: _FakeScheduleRepository([
            _race(
              id: '1',
              scheduledStartAt: DateTime.parse('2026-06-18T08:00:00'),
            ),
            _race(
              id: '2',
              scheduledStartAt: DateTime.parse('2026-06-19T08:00:00'),
            ),
            _race(id: '3', scheduledStartAt: null),
          ]),
        );

        await viewModel.loadSchedule();

        expect(viewModel.selectedDateKey, '2026-06-18');
        expect(viewModel.visibleRaces.map((race) => race.id), ['1']);

        viewModel.selectDate('2026-06-19');
        expect(viewModel.visibleRaces.map((race) => race.id), ['2']);
      },
    );

    test(
      'list mode returns all API races without losing source list',
      () async {
        final viewModel = JockeyScheduleViewModel(
          repository: _FakeScheduleRepository([
            _race(
              id: '1',
              scheduledStartAt: DateTime.parse('2026-06-18T08:00:00'),
            ),
            _race(id: '2', scheduledStartAt: null),
          ]),
        );

        await viewModel.loadSchedule();
        viewModel.setViewMode(JockeyScheduleViewMode.list);

        expect(viewModel.visibleRaces.map((race) => race.id), ['1', '2']);
        viewModel.setViewMode(JockeyScheduleViewMode.calendar);
        expect(viewModel.visibleRaces.map((race) => race.id), ['1']);
      },
    );

    test(
      'exposes error and clears selected date when repository fails',
      () async {
        final viewModel = JockeyScheduleViewModel(
          repository: _FailingScheduleRepository(),
        );

        await viewModel.loadSchedule();

        expect(viewModel.data, isNull);
        expect(viewModel.selectedDateKey, isNull);
        expect(viewModel.isLoading, isFalse);
        expect(viewModel.errorMessage, 'Không thể tải lịch thi đấu.');
      },
    );
  });
}

class _FakeScheduleRepository extends JockeyScheduleRepository {
  _FakeScheduleRepository(this.races);

  final List<JockeyRaceResponse> races;

  @override
  Future<JockeyScheduleData> fetchSchedule() async {
    return JockeyScheduleData.fromResponses(races);
  }
}

class _FailingScheduleRepository extends JockeyScheduleRepository {
  @override
  Future<JockeyScheduleData> fetchSchedule() {
    throw Exception('schedule api failed');
  }
}

JockeyRaceResponse _race({
  String id = '22',
  String? tournamentId = '7',
  String? name = 'Autumn Sprint',
  String? distance = '1600m',
  String? venueName = 'Saigon Track',
  String? venueAddress,
  String? provinceName = 'HCMC',
  DateTime? scheduledStartAt,
  DateTime? scheduledEndAt,
  String? refereeUsername = 'referee01',
  String? status = 'SCHEDULED',
  int participantCount = 8,
}) {
  return JockeyRaceResponse(
    id: id,
    tournamentId: tournamentId,
    name: name,
    distance: distance,
    venueName: venueName,
    venueAddress: venueAddress,
    provinceName: provinceName,
    scheduledStartAt: scheduledStartAt,
    scheduledEndAt: scheduledEndAt,
    refereeUsername: refereeUsername,
    status: status,
    participantCount: participantCount,
  );
}
