import '../models/referee_dashboard_data.dart';
import '../models/referee_race_response.dart';
import '../repositories/auth_repository.dart';
import '../services/referee_dashboard_service.dart';

class RefereeRepository {
  RefereeRepository({
    RefereeDashboardService? dashboardService,
    AuthRepository? authRepository,
  }) : _dashboardService = dashboardService ?? RefereeDashboardService(),
       _authRepository = authRepository ?? AuthRepository();

  final RefereeDashboardService _dashboardService;
  final AuthRepository _authRepository;

  Future<RefereeDashboardData> fetchDashboard() async {
    final dashboard = await _dashboardService.getDashboard();

    var assignedRaces = const <RefereeRaceResponse>[];
    var violationCount = 0;
    String? profileImageUrl;

    await Future.wait([
      (() async {
        try {
          assignedRaces = await _dashboardService
              .getAssignedRacesWithParticipantCounts();
        } catch (_) {}
      })(),
      (() async {
        try {
          violationCount = await _dashboardService.getViolationCount();
        } catch (_) {}
      })(),
      (() async {
        profileImageUrl = await _loadProfileImageUrl();
      })(),
    ]);

    return RefereeDashboardData.fromApi(
      dashboard: dashboard,
      assignedRaces: assignedRaces,
      violationCount: violationCount,
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
