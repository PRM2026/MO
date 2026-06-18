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
  String? loadError;
  JockeyInvitationDetail? data;

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
}
