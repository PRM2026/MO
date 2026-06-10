import '../models/jockey_dashboard_data.dart';
import '../repositories/auth_repository.dart';

class JockeyDashboardRepository {
  JockeyDashboardRepository({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  final AuthRepository _authRepository;

  Future<JockeyDashboardData> fetchDashboard() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final profile = await _authRepository.loadProfile();
    return JockeyDashboardData.sample(fullName: profile.fullName);
  }
}
