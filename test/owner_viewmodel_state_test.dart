import 'package:flutter_test/flutter_test.dart';
import 'package:horse_racing/src/models/owner_dashboard_data.dart';
import 'package:horse_racing/src/models/user_profile.dart';
import 'package:horse_racing/src/repositories/auth_repository.dart';
import 'package:horse_racing/src/repositories/owner_dashboard_repository.dart';
import 'package:horse_racing/src/viewmodels/owner_dashboard_viewmodel.dart';
import 'package:horse_racing/src/viewmodels/owner_profile_viewmodel.dart';

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
