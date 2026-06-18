import 'package:flutter/foundation.dart';

import '../models/owner_horse_item.dart';
import '../models/owner_jockey_invitation.dart';
import '../models/owner_tournament_detail.dart';
import '../models/tournament_list_item.dart';
import '../repositories/owner_horse_repository.dart';
import '../repositories/owner_jockey_invitation_repository.dart';
import '../repositories/owner_tournament_repository.dart';
import '../services/owner_jockey_invitation_service.dart';

enum OwnerInvitationFilter { all, pending, accepted, rejected, cancelled }

extension OwnerInvitationFilterX on OwnerInvitationFilter {
  String get label {
    return switch (this) {
      OwnerInvitationFilter.all => 'Tất cả',
      OwnerInvitationFilter.pending => 'Chờ phản hồi',
      OwnerInvitationFilter.accepted => 'Đã nhận',
      OwnerInvitationFilter.rejected => 'Từ chối',
      OwnerInvitationFilter.cancelled => 'Đã hủy',
    };
  }

  bool matches(OwnerJockeyInvitation invitation) {
    return switch (this) {
      OwnerInvitationFilter.all => true,
      OwnerInvitationFilter.pending => invitation.statusCode == 'PENDING',
      OwnerInvitationFilter.accepted => invitation.statusCode == 'ACCEPTED',
      OwnerInvitationFilter.rejected => invitation.statusCode == 'REJECTED',
      OwnerInvitationFilter.cancelled => invitation.statusCode == 'CANCELLED',
    };
  }
}

class OwnerInvitationRaceOption {
  const OwnerInvitationRaceOption({
    required this.id,
    required this.name,
    required this.tournamentId,
    required this.tournamentName,
  });

  final String id;
  final String name;
  final String tournamentId;
  final String tournamentName;

  String get label => tournamentName.isEmpty ? name : '$name • $tournamentName';
}

class OwnerJockeyInvitationsViewModel extends ChangeNotifier {
  OwnerJockeyInvitationsViewModel({
    OwnerJockeyInvitationRepository? repository,
  }) : _repository = repository ?? OwnerJockeyInvitationRepository();

  final OwnerJockeyInvitationRepository _repository;

  bool isLoading = false;
  String? errorMessage;
  List<OwnerJockeyInvitation> invitations = const [];
  OwnerInvitationFilter selectedFilter = OwnerInvitationFilter.all;

  List<OwnerJockeyInvitation> get filteredInvitations {
    return invitations.where(selectedFilter.matches).toList(growable: false);
  }

  Future<void> loadInvitations() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      invitations = await _repository.fetchInvitations();
    } catch (error) {
      invitations = const [];
      errorMessage = _messageFrom(error, 'Không thể tải lời mời jockey.');
      if (kDebugMode) debugPrint('OwnerJockeyInvitationsViewModel: $error');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshInvitations() => loadInvitations();

  void selectFilter(OwnerInvitationFilter filter) {
    selectedFilter = filter;
    notifyListeners();
  }
}

class OwnerJockeyInvitationDetailViewModel extends ChangeNotifier {
  OwnerJockeyInvitationDetailViewModel({
    required this.invitationId,
    OwnerJockeyInvitationRepository? repository,
  }) : _repository = repository ?? OwnerJockeyInvitationRepository();

  final String invitationId;
  final OwnerJockeyInvitationRepository _repository;

  bool isLoading = false;
  bool isCancelling = false;
  String? errorMessage;
  String? cancelError;
  OwnerJockeyInvitation? detail;

  Future<void> loadDetail() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      detail = await _repository.fetchInvitationDetail(invitationId);
    } catch (error) {
      detail = null;
      errorMessage = _messageFrom(error, 'Không thể tải chi tiết lời mời.');
      if (kDebugMode) {
        debugPrint('OwnerJockeyInvitationDetailViewModel: $error');
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => loadDetail();

  Future<bool> cancelInvitation() async {
    isCancelling = true;
    cancelError = null;
    notifyListeners();

    try {
      final updated = await _repository.cancelInvitation(invitationId);
      if (updated != null) detail = updated;
      return true;
    } catch (error) {
      cancelError = _messageFrom(error, 'Không thể hủy lời mời.');
      if (kDebugMode) {
        debugPrint('OwnerJockeyInvitationDetailViewModel cancel: $error');
      }
      return false;
    } finally {
      isCancelling = false;
      notifyListeners();
    }
  }
}

class OwnerAcceptedJockeysViewModel extends ChangeNotifier {
  OwnerAcceptedJockeysViewModel({
    OwnerJockeyInvitationRepository? repository,
  }) : _repository = repository ?? OwnerJockeyInvitationRepository();

  final OwnerJockeyInvitationRepository _repository;

  bool isLoading = false;
  String? errorMessage;
  List<OwnerAcceptedJockey> jockeys = const [];

  Future<void> loadJockeys() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      jockeys = await _repository.fetchAcceptedJockeys();
    } catch (error) {
      jockeys = const [];
      errorMessage = _messageFrom(error, 'Không thể tải jockey đã nhận lời.');
      if (kDebugMode) debugPrint('OwnerAcceptedJockeysViewModel: $error');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshJockeys() => loadJockeys();
}

class OwnerCreateJockeyInvitationViewModel extends ChangeNotifier {
  OwnerCreateJockeyInvitationViewModel({
    this.initialHorseId,
    this.initialHorseName,
    this.initialRaceId,
    this.initialRaceName,
    this.initialTournamentId,
    this.initialTournamentName,
    OwnerJockeyInvitationRepository? invitationRepository,
    OwnerHorseRepository? horseRepository,
    OwnerTournamentRepository? tournamentRepository,
  }) : _invitationRepository =
           invitationRepository ?? OwnerJockeyInvitationRepository(),
       _horseRepository = horseRepository ?? OwnerHorseRepository(),
       _tournamentRepository =
           tournamentRepository ?? OwnerTournamentRepository() {
    selectedHorseId = initialHorseId;
    selectedRaceId = initialRaceId;
    selectedTournamentId = initialTournamentId;
    if (initialRaceId != null && initialRaceName != null) {
      raceOptions = [
        OwnerInvitationRaceOption(
          id: initialRaceId!,
          name: initialRaceName!,
          tournamentId: initialTournamentId ?? '',
          tournamentName: initialTournamentName ?? '',
        ),
      ];
    }
  }

  final String? initialHorseId;
  final String? initialHorseName;
  final String? initialRaceId;
  final String? initialRaceName;
  final String? initialTournamentId;
  final String? initialTournamentName;
  final OwnerJockeyInvitationRepository _invitationRepository;
  final OwnerHorseRepository _horseRepository;
  final OwnerTournamentRepository _tournamentRepository;

  bool isLoading = false;
  bool isLoadingRaces = false;
  bool isSubmitting = false;
  String? errorMessage;
  String? raceErrorMessage;
  String? submitError;
  List<OwnerHorseItem> approvedHorses = const [];
  List<OwnerAvailableJockey> availableJockeys = const [];
  List<TournamentListItem> tournaments = const [];
  List<OwnerInvitationRaceOption> raceOptions = const [];
  String? selectedHorseId;
  String? selectedTournamentId;
  String? selectedRaceId;
  String? selectedJockeyId;

  bool get hasLockedRace => initialRaceId != null;

  Future<void> loadOptions() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final horses = await _horseRepository.fetchHorses();
      approvedHorses = horses
          .where((horse) => horse.statusCode == 'APPROVED')
          .toList(growable: false);
      availableJockeys = await _invitationRepository.fetchAvailableJockeys();
      if (!hasLockedRace) {
        tournaments = await _tournamentRepository.fetchTournaments();
      }
      _ensureInitialHorseOption();
    } catch (error) {
      errorMessage = _messageFrom(error, 'Không thể tải dữ liệu tạo lời mời.');
      approvedHorses = const [];
      availableJockeys = const [];
      tournaments = const [];
      if (kDebugMode) debugPrint('OwnerCreateJockeyInvitationViewModel: $error');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void selectHorse(String? id) {
    selectedHorseId = id;
    notifyListeners();
  }

  void selectJockey(String? id) {
    selectedJockeyId = id;
    notifyListeners();
  }

  Future<void> selectTournament(String? id) async {
    selectedTournamentId = id;
    selectedRaceId = null;
    raceOptions = const [];
    raceErrorMessage = null;
    notifyListeners();

    if (id == null || id.trim().isEmpty) return;

    isLoadingRaces = true;
    notifyListeners();
    try {
      final detail = await _tournamentRepository.fetchTournamentDetail(id);
      raceOptions = detail.races
          .where(_canInviteRace)
          .map(
            (race) => OwnerInvitationRaceOption(
              id: race.id,
              name: race.name,
              tournamentId: detail.id,
              tournamentName: detail.name,
            ),
          )
          .toList(growable: false);
    } catch (error) {
      raceErrorMessage = _messageFrom(error, 'Không thể tải cuộc đua.');
      if (kDebugMode) debugPrint('OwnerCreateJockeyInvitationViewModel race: $error');
    } finally {
      isLoadingRaces = false;
      notifyListeners();
    }
  }

  void selectRace(String? id) {
    selectedRaceId = id;
    notifyListeners();
  }

  String? validate({required String remunerationText, required String message}) {
    final amount = _parseAmount(remunerationText);
    if (remunerationText.trim().isNotEmpty && amount == null) {
      return 'Thù lao phải là số.';
    }
    return OwnerJockeyInvitationFormData(
      horseId: _parseId(selectedHorseId),
      raceId: _parseId(selectedRaceId),
      jockeyId: _parseId(selectedJockeyId),
      remunerationAmount: amount,
      message: message,
    ).validate();
  }

  Future<bool> submit({
    required String remunerationText,
    required String message,
  }) async {
    submitError = validate(
      remunerationText: remunerationText,
      message: message,
    );
    if (submitError != null) {
      notifyListeners();
      return false;
    }

    isSubmitting = true;
    submitError = null;
    notifyListeners();

    try {
      await _invitationRepository.createInvitation(
        OwnerJockeyInvitationFormData(
          horseId: _parseId(selectedHorseId),
          raceId: _parseId(selectedRaceId),
          jockeyId: _parseId(selectedJockeyId),
          remunerationAmount: _parseAmount(remunerationText),
          message: message,
        ),
      );
      return true;
    } catch (error) {
      submitError = _messageFrom(error, 'Không thể tạo lời mời jockey.');
      if (kDebugMode) {
        debugPrint('OwnerCreateJockeyInvitationViewModel submit: $error');
      }
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  void _ensureInitialHorseOption() {
    if (initialHorseId == null || initialHorseName == null) return;
    if (approvedHorses.any((horse) => horse.id == initialHorseId)) return;
    approvedHorses = [
      OwnerHorseItem(
        id: initialHorseId!,
        name: initialHorseName!,
        breed: '',
        imageUrl: '',
        documentUrl: '',
        statusCode: 'APPROVED',
        statusLabel: 'Đã duyệt',
      ),
      ...approvedHorses,
    ];
  }
}

bool _canInviteRace(OwnerTournamentRace race) {
  return !{'CANCELLED', 'COMPLETED', 'RESULT_CONFIRMED'}.contains(race.status);
}

int? _parseId(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  return int.tryParse(value.trim());
}

num? _parseAmount(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return null;
  return num.tryParse(trimmed.replaceAll(',', '.'));
}

String _messageFrom(Object error, String fallback) {
  final text = error.toString().trim();
  if (text.isEmpty) return fallback;
  return text
      .replaceFirst('OwnerJockeyInvitationApiException: ', '')
      .replaceFirst('OwnerApiException: ', '')
      .replaceFirst('ApiException: ', '')
      .replaceFirst('Exception: ', '');
}
