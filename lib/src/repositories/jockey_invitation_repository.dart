import '../models/jockey_invitation_data.dart';
import '../services/jockey_invitation_service.dart';

class JockeyInvitationRepository {
  JockeyInvitationRepository({JockeyInvitationService? service})
    : _service = service ?? JockeyInvitationService();

  final JockeyInvitationService _service;

  Future<List<JockeyInvitationListItem>> fetchInvitations() async {
    final responses = await _service.getJockeyInvitations();
    return responses.map((item) => item.toListItem()).toList(growable: false);
  }

  Future<JockeyInvitationDetail> fetchInvitationDetail(String id) async {
    final response = await _service.getJockeyInvitation(_parseInvitationId(id));
    return response.toDetail();
  }

  Future<void> acceptInvitation(String id, {String? note}) async {
    await _service.acceptInvitation(_parseInvitationId(id), note: note);
  }

  Future<void> rejectInvitation(String id, {String? note}) async {
    await _service.rejectInvitation(_parseInvitationId(id), note: note);
  }

  String _parseInvitationId(String id) {
    final invitationId = id.trim();
    final isLegacyNumeric =
        int.tryParse(invitationId) != null &&
        (int.tryParse(invitationId) ?? 0) > 0;
    final isObjectId = RegExp(r'^[a-fA-F0-9]{24}$').hasMatch(invitationId);
    if (!isLegacyNumeric && !isObjectId) {
      throw const JockeyInvitationApiException(
        'Không xác định được mã lời mời.',
      );
    }
    return Uri.encodeComponent(invitationId);
  }
}
