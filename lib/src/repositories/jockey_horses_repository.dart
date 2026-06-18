import '../models/jockey_horse_data.dart';
import '../models/jockey_invitation_response.dart';
import '../models/jockey_profile_response.dart';
import '../models/jockey_race_response.dart';
import '../services/jockey_invitation_service.dart';
import '../services/jockey_profile_service.dart';
import '../services/jockey_race_service.dart';

class JockeyHorsesRepository {
  JockeyHorsesRepository({
    JockeyInvitationService? invitationService,
    JockeyRaceService? raceService,
    JockeyProfileService? profileService,
  }) : _invitationService = invitationService ?? JockeyInvitationService(),
       _raceService = raceService ?? JockeyRaceService(),
       _profileService = profileService ?? JockeyProfileService();

  final JockeyInvitationService _invitationService;
  final JockeyRaceService _raceService;
  final JockeyProfileService _profileService;

  Future<JockeyHorseAssignmentsData> fetchAssignments() async {
    final invitations = await _invitationService.getJockeyInvitations();
    final accepted = invitations
        .where((invitation) => invitation.statusCode == 'ACCEPTED')
        .toList(growable: false);

    if (accepted.isEmpty) {
      final profile = await _loadProfile();
      return JockeyHorseAssignmentsData(
        assignments: const [],
        profileImageUrl: _profileImage(profile),
      );
    }

    final enrichment = await Future.wait<Object?>([
      _loadRaces(),
      _loadProfile(),
    ]);
    final races = enrichment[0] as List<JockeyRaceResponse>;
    final profile = enrichment[1] as JockeyProfileResponse?;
    final racesById = {for (final race in races) race.id: race};
    final history = profile?.raceHistory ?? const <JockeyRaceHistoryItem>[];

    return JockeyHorseAssignmentsData(
      assignments: accepted
          .map((invitation) => _mapAssignment(invitation, racesById, history))
          .toList(growable: false),
      profileImageUrl: _profileImage(profile),
    );
  }

  Future<List<JockeyRaceResponse>> _loadRaces() async {
    try {
      return await _raceService.getJockeyRaces();
    } catch (_) {
      return const [];
    }
  }

  Future<JockeyProfileResponse?> _loadProfile() async {
    try {
      return await _profileService.getMyProfile();
    } catch (_) {
      return null;
    }
  }
}

JockeyHorseAssignmentItem _mapAssignment(
  JockeyInvitationResponse invitation,
  Map<String, JockeyRaceResponse> racesById,
  List<JockeyRaceHistoryItem> history,
) {
  final invitationRaceId = invitation.raceId?.toString();
  final race = invitationRaceId == null ? null : racesById[invitationRaceId];
  final historyItem = _resolveHistory(invitation, history);

  return JockeyHorseAssignmentItem(
    invitationId: invitation.idString,
    horseId: invitation.horseId,
    horseName: _firstNonEmpty([
      invitation.horseName,
      historyItem?.horseName,
      invitation.horseId == null ? null : 'Ngựa #${invitation.horseId}',
      'Ngựa chưa cập nhật',
    ]),
    ownerUsername: _firstNonEmpty([
      invitation.ownerUsername,
      invitation.ownerId == null ? null : 'Owner #${invitation.ownerId}',
      'Chủ ngựa chưa cập nhật',
    ]),
    raceId: race?.id ?? invitationRaceId ?? _positiveId(historyItem?.raceId),
    raceName: _firstNonEmpty([
      race?.name,
      invitation.raceName,
      historyItem?.raceName,
      invitationRaceId == null ? null : 'Cuộc đua #$invitationRaceId',
      'Chưa gắn cuộc đua',
    ]),
    tournamentId:
        race?.tournamentId ??
        invitation.tournamentId?.toString() ??
        _positiveId(historyItem?.tournamentId),
    tournamentName: _firstNonEmpty([
      invitation.tournamentName,
      historyItem?.tournamentName,
      invitation.tournamentId == null
          ? null
          : 'Giải đấu #${invitation.tournamentId}',
      'Chưa gắn giải đấu',
    ]),
    assignmentStatusCode: invitation.statusCode,
    raceStatusCode: _firstNonEmpty([
      race?.status?.toUpperCase(),
      historyItem?.status?.toUpperCase(),
      '',
    ]),
    remunerationAmount: invitation.remunerationAmount ?? 0,
    scheduledStartAt: race?.scheduledStartAt ?? historyItem?.scheduledStartAt,
    hasRaceDetail: race != null,
  );
}

JockeyRaceHistoryItem? _resolveHistory(
  JockeyInvitationResponse invitation,
  List<JockeyRaceHistoryItem> history,
) {
  for (final item in history) {
    if (invitation.raceId != null &&
        invitation.horseId != null &&
        item.raceId == invitation.raceId &&
        item.horseId == invitation.horseId) {
      return item;
    }
  }
  for (final item in history) {
    if (invitation.raceId != null && item.raceId == invitation.raceId) {
      return item;
    }
  }
  for (final item in history) {
    if (invitation.horseId != null && item.horseId == invitation.horseId) {
      return item;
    }
  }
  return null;
}

String _firstNonEmpty(List<String?> values) {
  for (final value in values) {
    final trimmed = value?.trim();
    if (trimmed != null && trimmed.isNotEmpty) return trimmed;
  }
  return '';
}

String? _positiveId(int? value) => value != null && value > 0 ? '$value' : null;

String? _profileImage(JockeyProfileResponse? profile) {
  final value = profile?.avatarUrl?.trim();
  return value == null || value.isEmpty ? null : value;
}
