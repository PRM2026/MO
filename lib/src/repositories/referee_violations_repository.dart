import '../models/violation_record.dart';
import '../repositories/auth_repository.dart';
import '../services/referee_dashboard_service.dart';

class RefereeViolationsRepository {
  RefereeViolationsRepository({
    RefereeDashboardService? dashboardService,
    AuthRepository? authRepository,
  }) : _dashboardService = dashboardService ?? RefereeDashboardService(),
       _authRepository = authRepository ?? AuthRepository();

  final RefereeDashboardService _dashboardService;
  final AuthRepository _authRepository;

  Future<ViolationsPageData> fetchPageData() async {
    final violations = await _dashboardService.getViolations();
    String? profileImageUrl;
    try {
      final user = await _authRepository.refreshCurrentUser();
      final avatar = user.avatarUrl?.trim();
      profileImageUrl = avatar == null || avatar.isEmpty ? null : avatar;
    } catch (_) {}

    return ViolationsPageData.fromApi(
      violations: violations,
      profileImageUrl: profileImageUrl,
    );
  }
}
