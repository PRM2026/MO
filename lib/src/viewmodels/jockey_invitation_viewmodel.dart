import 'package:flutter/foundation.dart';

import '../models/jockey_invitation_data.dart';
import '../repositories/jockey_invitation_repository.dart';
import '../services/jockey_invitation_service.dart';

class JockeyInvitationsViewModel extends ChangeNotifier {
  JockeyInvitationsViewModel({JockeyInvitationRepository? repository})
      : _repository = repository ?? JockeyInvitationRepository();

  final JockeyInvitationRepository _repository;

  bool isLoading = false;
  String? loadError;
  List<JockeyInvitationListItem> invitations = const [];

  Future<void> loadInvitations() async {
    isLoading = true;
    loadError = null;
    notifyListeners();

    try {
      invitations = await _repository.fetchInvitations();
    } on JockeyInvitationApiException catch (error) {
      loadError = error.message;
      invitations = const [];
      if (kDebugMode) debugPrint('JockeyInvitationsViewModel: $error');
    } catch (error) {
      loadError = 'Không tải được danh sách lời mời.';
      invitations = const [];
      if (kDebugMode) debugPrint('JockeyInvitationsViewModel: $error');
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
  }) : _repository = repository ?? JockeyInvitationRepository();

  final String invitationId;
  final JockeyInvitationRepository _repository;

  bool isLoading = false;
  bool isProcessing = false;
  String? loadError;
  String? actionError;
  JockeyInvitationDetail? data;

  Future<void> loadDetail() async {
    isLoading = true;
    loadError = null;
    notifyListeners();

    try {
      data = await _repository.fetchInvitationDetail(invitationId);
    } on JockeyInvitationApiException catch (error) {
      loadError = error.message;
      if (kDebugMode) debugPrint('JockeyInvitationDetailViewModel: $error');
    } catch (error) {
      loadError = 'Không tải được chi tiết lời mời.';
      if (kDebugMode) debugPrint('JockeyInvitationDetailViewModel: $error');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> acceptInvitation({String? note}) async {
    return _runAction(() => _repository.acceptInvitation(invitationId, note: note));
  }

  Future<bool> declineInvitation({String? note}) async {
    return _runAction(() => _repository.rejectInvitation(invitationId, note: note));
  }

  Future<bool> _runAction(Future<void> Function() action) async {
    isProcessing = true;
    actionError = null;
    notifyListeners();

    try {
      await action();
      return true;
    } on JockeyInvitationApiException catch (error) {
      actionError = error.message;
      if (kDebugMode) debugPrint('JockeyInvitationDetailViewModel: $error');
      return false;
    } catch (error) {
      actionError = 'Không thể cập nhật lời mời. Vui lòng thử lại.';
      if (kDebugMode) debugPrint('JockeyInvitationDetailViewModel: $error');
      return false;
    } finally {
      isProcessing = false;
      notifyListeners();
    }
  }
}
