import '../models/owner_jockey_invitation.dart';
import '../services/owner_jockey_invitation_service.dart';

class OwnerJockeyInvitationRepository {
  OwnerJockeyInvitationRepository({OwnerJockeyInvitationService? service})
    : _service = service ?? OwnerJockeyInvitationService();

  final OwnerJockeyInvitationService _service;

  Future<List<OwnerJockeyInvitation>> fetchInvitations() {
    return _service.getInvitations();
  }

  Future<OwnerJockeyInvitation> fetchInvitationDetail(String id) {
    return _service.getInvitation(id);
  }

  Future<OwnerJockeyInvitation> createInvitation(
    OwnerJockeyInvitationFormData data,
  ) {
    return _service.createInvitation(data);
  }

  Future<OwnerJockeyInvitation?> cancelInvitation(String id) {
    return _service.cancelInvitation(id);
  }

  Future<List<OwnerAcceptedJockey>> fetchAcceptedJockeys() {
    return _service.getAcceptedJockeys();
  }

  Future<List<OwnerAvailableJockey>> fetchAvailableJockeys() {
    return _service.getAvailableJockeys();
  }
}
