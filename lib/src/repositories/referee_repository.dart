import '../models/referee_dashboard_data.dart';
import '../models/referee_race_response.dart';
import '../repositories/auth_repository.dart';
import '../services/referee_dashboard_service.dart';

class RefereeRepository {
  RefereeRepository({
    RefereeDashboardService? dashboardService,
    AuthRepository? authRepository,
  })  : _dashboardService = dashboardService ?? RefereeDashboardService(),
        _authRepository = authRepository ?? AuthRepository();

  final RefereeDashboardService _dashboardService;
  final AuthRepository _authRepository;

  Future<RefereeDashboardData> fetchDashboard() async {
    final dashboard = await _dashboardService.getDashboard();

    var assignedRaces = const <RefereeRaceResponse>[];
    try {
      assignedRaces = await _dashboardService.getAssignedRaces();
    } catch (_) {}

    final profileImageUrl = await _loadProfileImageUrl();

    return RefereeDashboardData.fromApi(
      dashboard: dashboard,
      assignedRaces: assignedRaces,
      profileImageUrl: profileImageUrl,
    );
  }

  Future<String?> _loadProfileImageUrl() async {
    try {
      final user = await _authRepository.refreshCurrentUser();
      final avatar = user.avatarUrl?.trim();
      return avatar == null || avatar.isEmpty ? null : avatar;
    } catch (_) {
      return null;
    }
  }
}
