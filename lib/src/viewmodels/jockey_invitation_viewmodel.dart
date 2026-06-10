import 'package:flutter/foundation.dart';

import '../models/jockey_invitation_data.dart';
import '../repositories/jockey_invitation_repository.dart';

class JockeyInvitationsViewModel extends ChangeNotifier {
  JockeyInvitationsViewModel({JockeyInvitationRepository? repository})
      : _repository = repository ?? const JockeyInvitationRepository();

  final JockeyInvitationRepository _repository;

  bool isLoading = false;
  List<JockeyInvitationListItem> invitations = const [];

  Future<void> loadInvitations() async {
    isLoading = true;
    notifyListeners();

    try {
      invitations = await _repository.fetchInvitations();
    } catch (error) {
      if (kDebugMode) debugPrint('JockeyInvitationsViewModel: $error');
      invitations = JockeyInvitationDetail.sampleList();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

class JockeyInvitationDetailViewModel extends ChangeNotifier {
  JockeyInvitationDetailViewModel({
    required this.invitationId,
    JockeyInvitationRepository? repository,
  }) : _repository = repository ?? const JockeyInvitationRepository();

  final String invitationId;
  final JockeyInvitationRepository _repository;

  bool isLoading = false;
  bool isProcessing = false;
  JockeyInvitationDetail? data;

  Future<void> loadDetail() async {
    isLoading = true;
    notifyListeners();

    try {
      data = await _repository.fetchInvitationDetail(invitationId);
    } catch (error) {
      if (kDebugMode) debugPrint('JockeyInvitationDetailViewModel: $error');
      data = JockeyInvitationDetail.sample();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> acceptInvitation() async {
    isProcessing = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 400));
    isProcessing = false;
    notifyListeners();
    return true;
  }

  Future<bool> declineInvitation() async {
    isProcessing = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 400));
    isProcessing = false;
    notifyListeners();
    return true;
  }
}
