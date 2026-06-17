import '../models/referee_race_participant_response.dart';
import '../models/referee_race_result_response.dart';
import '../models/race_result_confirmation.dart';
import '../models/referee_race_response.dart';
import '../repositories/auth_repository.dart';
import '../services/referee_dashboard_service.dart';

class RefereeHistoryRepository {
  RefereeHistoryRepository({
    RefereeDashboardService? dashboardService,
    AuthRepository? authRepository,
  })  : _dashboardService = dashboardService ?? RefereeDashboardService(),
        _authRepository = authRepository ?? AuthRepository();

  final RefereeDashboardService _dashboardService;
  final AuthRepository _authRepository;

  List<RefereeRaceResponse> _cachedRaces = const [];

  Future<RaceResultConfirmationData> fetchPageData({int? raceId}) async {
    final profileImageUrl = await _loadProfileImageUrl();
    _cachedRaces = await _dashboardService.getAssignedRaces();

    final relevant = _cachedRaces
        .where(
          (race) =>
              race.status == 'ONGOING' || race.status == 'RESULT_CONFIRMED',
        )
        .toList(growable: false);

    if (relevant.isEmpty) {
      return RaceResultConfirmationData.empty(profileImageUrl: profileImageUrl);
    }

    final selected = _pickRace(relevant, raceId);
    return _buildRaceData(
      allRaces: _cachedRaces,
      selectedRace: selected,
      profileImageUrl: profileImageUrl,
    );
  }

  Future<RaceResultConfirmationData> fetchRaceDetails(int raceId) async {
    final profileImageUrl = await _loadProfileImageUrl();
    if (_cachedRaces.isEmpty) {
      _cachedRaces = await _dashboardService.getAssignedRaces();
    }

    final selected = _cachedRaces.firstWhere(
      (race) => race.id == raceId,
      orElse: () => _pickRace(_cachedRaces, raceId),
    );

    return _buildRaceData(
      allRaces: _cachedRaces,
      selectedRace: selected,
      profileImageUrl: profileImageUrl,
    );
  }

  RefereeRaceResponse _pickRace(
    List<RefereeRaceResponse> relevant,
    int? raceId,
  ) {
    if (raceId != null) {
      return relevant.firstWhere(
        (race) => race.id == raceId,
        orElse: () => relevant.first,
      );
    }

    return relevant.firstWhere(
      (race) => race.status == 'RESULT_CONFIRMED',
      orElse: () => relevant.firstWhere(
        (race) => race.status == 'ONGOING',
        orElse: () => relevant.first,
      ),
    );
  }

  Future<RaceResultConfirmationData> _buildRaceData({
    required List<RefereeRaceResponse> allRaces,
    required RefereeRaceResponse selectedRace,
    String? profileImageUrl,
  }) async {
    final id = selectedRace.id;
    if (id == null) {
      return RaceResultConfirmationData.empty(profileImageUrl: profileImageUrl);
    }

    var results = const <RefereeRaceResultResponse>[];
    var participants = const <RefereeRaceParticipantResponse>[];

    try {
      results = await _dashboardService.getRaceResults(id);
    } catch (_) {}

    try {
      participants = await _dashboardService.getRaceParticipants(id);
    } catch (_) {}

    return RaceResultConfirmationData.fromApi(
      allRaces: allRaces,
      selectedRace: selectedRace,
      results: results,
      participants: participants,
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
}
