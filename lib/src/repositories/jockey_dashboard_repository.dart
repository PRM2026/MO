import '../models/jockey_dashboard_data.dart';
import '../models/jockey_invitation_response.dart';
import '../repositories/auth_repository.dart';
import '../services/jockey_dashboard_service.dart';
import '../services/jockey_invitation_service.dart';

class JockeyDashboardRepository {
  JockeyDashboardRepository({
    JockeyDashboardService? dashboardService,
    JockeyInvitationService? invitationService,
    AuthRepository? authRepository,
  }) : _dashboardService = dashboardService ?? JockeyDashboardService(),
       _invitationService = invitationService ?? JockeyInvitationService(),
       _authRepository = authRepository ?? AuthRepository();

  final JockeyDashboardService _dashboardService;
  final JockeyInvitationService _invitationService;
  final AuthRepository _authRepository;

  Future<JockeyDashboardData> fetchDashboard() async {
    final dashboard = await _dashboardService.getDashboard();

    final profileImageUrl = await _loadProfileImageUrl();
    final pendingInvitationCount =
        dashboard.pendingInvitationCount ?? await _loadPendingInvitationCount();

    return JockeyDashboardData.fromApi(
      dashboard: dashboard,
      pendingInvitationCount: pendingInvitationCount,
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

  Future<int> _loadPendingInvitationCount() async {
    try {
      final invitations = await _invitationService.getJockeyInvitations();
      return invitations.where(_isPendingInvitation).length;
    } catch (_) {
      return 0;
    }
  }

  bool _isPendingInvitation(JockeyInvitationResponse invitation) {
    return invitation.statusCode == 'PENDING';
  }
}
