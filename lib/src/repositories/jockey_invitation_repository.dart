import '../models/jockey_invitation_data.dart';
import '../repositories/auth_repository.dart';
import '../services/jockey_invitation_service.dart';

class JockeyInvitationRepository {
  JockeyInvitationRepository({
    JockeyInvitationService? service,
    AuthRepository? authRepository,
  })  : _service = service ?? JockeyInvitationService(),
        _authRepository = authRepository ?? AuthRepository();

  final JockeyInvitationService _service;
  final AuthRepository _authRepository;

  Future<List<JockeyInvitationListItem>> fetchInvitations() async {
    final responses = await _service.getJockeyInvitations();
    return responses.map((item) => item.toListItem()).toList();
  }

  Future<JockeyInvitationDetail> fetchInvitationDetail(String id) async {
    final invitationId = int.tryParse(id);
    if (invitationId == null) {
      throw JockeyInvitationApiException('Không xác định được mã lời mời.');
    }

    String? profileImageUrl;
    try {
      final user = await _authRepository.refreshCurrentUser();
      profileImageUrl = user.avatarUrl;
    } catch (_) {}

    final response = await _service.getJockeyInvitation(invitationId);
    return response.toDetail(profileImageUrl: profileImageUrl);
  }

  Future<void> acceptInvitation(String id, {String? note}) async {
    final invitationId = int.tryParse(id);
    if (invitationId == null) {
      throw JockeyInvitationApiException('Không xác định được mã lời mời.');
    }
    await _service.acceptInvitation(invitationId, note: note);
  }

  Future<void> rejectInvitation(String id, {String? note}) async {
    final invitationId = int.tryParse(id);
    if (invitationId == null) {
      throw JockeyInvitationApiException('Không xác định được mã lời mời.');
    }
    await _service.rejectInvitation(invitationId, note: note);
  }
}
