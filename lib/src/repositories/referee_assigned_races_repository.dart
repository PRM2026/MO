import '../models/assigned_race_item.dart';
import '../repositories/auth_repository.dart';
import '../services/referee_dashboard_service.dart';

class RefereeAssignedRacesRepository {
  RefereeAssignedRacesRepository({
    RefereeDashboardService? dashboardService,
    AuthRepository? authRepository,
  })  : _dashboardService = dashboardService ?? RefereeDashboardService(),
        _authRepository = authRepository ?? AuthRepository();

  final RefereeDashboardService _dashboardService;
  final AuthRepository _authRepository;

  Future<AssignedRacesData> fetchAssignedRaces() async {
    final races = await _dashboardService.getAssignedRaces();
    final profileImageUrl = await _loadProfileImageUrl();

    return AssignedRacesData.fromApi(
      races: races,
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
