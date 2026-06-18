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
  JockeyInvitationFilter selectedFilter = JockeyInvitationFilter.all;

  List<JockeyInvitationListItem> get visibleInvitations {
    final status = selectedFilter.statusCode;
    if (status == null) return invitations;
    return invitations
        .where((invitation) => invitation.statusCode == status)
        .toList(growable: false);
  }

  String get emptyMessage {
    return selectedFilter == JockeyInvitationFilter.all
        ? 'Chưa có lời mời nào.'
        : 'Không có lời mời ở trạng thái ${selectedFilter.label.toLowerCase()}.';
  }

  void selectFilter(JockeyInvitationFilter filter) {
    if (selectedFilter == filter) return;
    selectedFilter = filter;
    notifyListeners();
  }

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
  bool actionCompleted = false;
  String? loadError;
  String? actionError;
  JockeyInvitationDetail? data;

  static const maxDecisionNoteLength = 1000;

  Future<void> loadDetail() async {
    isLoading = true;
    loadError = null;
    notifyListeners();

    try {
      data = await _repository.fetchInvitationDetail(invitationId);
    } on JockeyInvitationApiException catch (error) {
      data = null;
      loadError = error.message;
      if (kDebugMode) debugPrint('JockeyInvitationDetailViewModel: $error');
    } catch (error) {
      data = null;
      loadError = 'Không tải được chi tiết lời mời.';
      if (kDebugMode) debugPrint('JockeyInvitationDetailViewModel: $error');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> acceptInvitation({String? note}) {
    return _runAction(
      note: note,
      action: (trimmedNote) =>
          _repository.acceptInvitation(invitationId, note: trimmedNote),
    );
  }

  Future<bool> rejectInvitation({String? note}) {
    return _runAction(
      note: note,
      action: (trimmedNote) =>
          _repository.rejectInvitation(invitationId, note: trimmedNote),
    );
  }

  Future<bool> _runAction({
    required String? note,
    required Future<void> Function(String? note) action,
  }) async {
    if (isProcessing) return false;

    final trimmedNote = note?.trim();
    if (trimmedNote != null && trimmedNote.length > maxDecisionNoteLength) {
      actionError = 'Ghi chú tối đa 1000 ký tự.';
      notifyListeners();
      return false;
    }

    isProcessing = true;
    actionError = null;
    notifyListeners();

    try {
      await action(trimmedNote?.isEmpty == true ? null : trimmedNote);
      actionCompleted = true;
      await loadDetail();
      actionError = null;
      return true;
    } on JockeyInvitationApiException catch (error) {
      actionError = error.message;
      if (kDebugMode) debugPrint('JockeyInvitationDetailViewModel: $error');
      return false;
    } catch (error) {
      actionError = 'Không thể cập nhật lời mời.';
      if (kDebugMode) debugPrint('JockeyInvitationDetailViewModel: $error');
      return false;
    } finally {
      isProcessing = false;
      notifyListeners();
    }
  }
}
