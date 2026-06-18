import 'package:flutter_test/flutter_test.dart';
import 'package:horse_racing/src/models/jockey_dashboard_data.dart';
import 'package:horse_racing/src/models/jockey_horse_data.dart';
import 'package:horse_racing/src/models/jockey_profile_response.dart';
import 'package:horse_racing/src/models/jockey_results_data.dart';
import 'package:horse_racing/src/models/jockey_schedule_data.dart';
import 'package:horse_racing/src/repositories/jockey_dashboard_repository.dart';
import 'package:horse_racing/src/repositories/jockey_horses_repository.dart';
import 'package:horse_racing/src/repositories/jockey_profile_repository.dart';
import 'package:horse_racing/src/repositories/jockey_results_repository.dart';
import 'package:horse_racing/src/repositories/jockey_schedule_repository.dart';
import 'package:horse_racing/src/viewmodels/jockey_dashboard_viewmodel.dart';
import 'package:horse_racing/src/viewmodels/jockey_horses_viewmodel.dart';
import 'package:horse_racing/src/viewmodels/jockey_profile_viewmodel.dart';
import 'package:horse_racing/src/viewmodels/jockey_results_viewmodel.dart';
import 'package:horse_racing/src/viewmodels/jockey_schedule_viewmodel.dart';

void main() {
  group('Jockey ViewModel error state', () {
    test('dashboard keeps data null when repository fails', () async {
      final viewModel = JockeyDashboardViewModel(
        repository: _FailingJockeyDashboardRepository(),
      );

      await viewModel.loadDashboard();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.data, isNull);
      expect(viewModel.errorMessage, 'Khong the tai du lieu tong quan jockey.');
    });

    test(
      'schedule keeps data null and clears selected date on failure',
      () async {
        final viewModel = JockeyScheduleViewModel(
          repository: _FailingJockeyScheduleRepository(),
        );

        await viewModel.loadSchedule();

        expect(viewModel.isLoading, isFalse);
        expect(viewModel.data, isNull);
        expect(viewModel.selectedDateKey, isNull);
        expect(viewModel.visibleRaces, isEmpty);
        expect(viewModel.errorMessage, 'Không thể tải lịch thi đấu.');
      },
    );

    test('horses keeps data null when repository fails', () async {
      final viewModel = JockeyHorsesViewModel(
        repository: _FailingJockeyHorsesRepository(),
      );

      await viewModel.loadAssignments();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.data, isNull);
      expect(
        viewModel.errorMessage,
        'Không thể tải danh sách ngựa được phân công.',
      );
    });

    test('results keeps data null when repository fails', () async {
      final viewModel = JockeyResultsViewModel(
        repository: _FailingJockeyResultsRepository(),
      );

      await viewModel.loadResults();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.data, isNull);
      expect(viewModel.errorMessage, 'Khong the tai ket qua va thanh tich.');
    });

    test('profile keeps data null when repository fails', () async {
      final viewModel = JockeyProfileViewModel(
        repository: _FailingJockeyProfileRepository(),
      );

      await viewModel.loadData();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.data, isNull);
      expect(viewModel.errorMessage, 'Khong the tai ho so jockey.');
    });
  });
}

class _FailingJockeyDashboardRepository extends JockeyDashboardRepository {
  @override
  Future<JockeyDashboardData> fetchDashboard() {
    throw Exception('dashboard api failed');
  }
}

class _FailingJockeyScheduleRepository extends JockeyScheduleRepository {
  @override
  Future<JockeyScheduleData> fetchSchedule() {
    throw Exception('schedule api failed');
  }
}

class _FailingJockeyHorsesRepository extends JockeyHorsesRepository {
  @override
  Future<JockeyHorseAssignmentsData> fetchAssignments() {
    throw Exception('horses api failed');
  }
}

class _FailingJockeyResultsRepository extends JockeyResultsRepository {
  @override
  Future<JockeyResultsData> fetchResults() {
    throw Exception('results api failed');
  }
}

class _FailingJockeyProfileRepository extends JockeyProfileRepository {
  @override
  Future<JockeyProfileResponse> fetchProfile() {
    throw Exception('profile api failed');
  }
}
