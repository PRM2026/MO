import '../models/jockey_invitation_data.dart';

class JockeyInvitationRepository {
  const JockeyInvitationRepository();

  Future<List<JockeyInvitationListItem>> fetchInvitations() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return JockeyInvitationDetail.sampleList();
  }

  Future<JockeyInvitationDetail> fetchInvitationDetail(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return JockeyInvitationDetail.sample();
  }
}
