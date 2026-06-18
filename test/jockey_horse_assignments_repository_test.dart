import 'package:flutter_test/flutter_test.dart';
import 'package:horse_racing/src/models/jockey_invitation_response.dart';
import 'package:horse_racing/src/models/jockey_profile_response.dart';
import 'package:horse_racing/src/models/jockey_race_response.dart';
import 'package:horse_racing/src/repositories/jockey_horses_repository.dart';
import 'package:horse_racing/src/services/jockey_invitation_service.dart';
import 'package:horse_racing/src/services/jockey_profile_service.dart';
import 'package:horse_racing/src/services/jockey_race_service.dart';

void main() {
  test(
    'keeps only accepted invitations and joins current race context',
    () async {
      final repository = _repository(
        invitations: [
          _invitation(id: 9, status: 'PENDING'),
          _invitation(id: 8, status: 'ACCEPTED'),
          _invitation(id: 7, status: 'ACCEPTED'),
        ],
        races: [_race()],
        profile: _profile(),
      );

      final data = await repository.fetchAssignments();

      expect(data.assignments, hasLength(2));
      expect(data.assignments.map((item) => item.invitationId), ['8', '7']);
      final assignment = data.assignments.first;
      expect(assignment.horseName, 'Night Wind');
      expect(assignment.raceName, 'Race API Name');
      expect(assignment.tournamentName, 'National Cup');
      expect(
        assignment.scheduledStartAt,
        DateTime.parse('2026-07-01T08:00:00'),
      );
      expect(assignment.raceStatusCode, 'SCHEDULED');
      expect(assignment.hasRaceDetail, isTrue);
      expect(data.profileImageUrl, 'https://example.test/avatar.png');
    },
  );

  test('does not merge two accepted assignments for the same horse', () async {
    final repository = _repository(
      invitations: [
        _invitation(id: 8, status: 'ACCEPTED'),
        _invitation(id: 7, status: 'ACCEPTED'),
      ],
    );

    final data = await repository.fetchAssignments();

    expect(data.assignments, hasLength(2));
  });

  test('uses profile history when race response is unavailable', () async {
    final repository = _repository(
      invitations: [
        _invitation(
          id: 7,
          status: 'ACCEPTED',
          raceName: null,
          tournamentName: null,
        ),
      ],
      raceError: true,
      profile: _profile(),
    );

    final assignment = (await repository.fetchAssignments()).assignments.single;

    expect(assignment.raceName, 'History Race');
    expect(assignment.tournamentName, 'History Tournament');
    expect(assignment.scheduledStartAt, DateTime.parse('2026-06-12T10:00:00'));
    expect(assignment.raceStatusCode, 'FINISHED');
    expect(assignment.hasRaceDetail, isFalse);
  });

  test('keeps accepted assignment when both enrichment APIs fail', () async {
    final repository = _repository(
      invitations: [_invitation(id: 7, status: 'ACCEPTED')],
      raceError: true,
      profileError: true,
    );

    final data = await repository.fetchAssignments();

    expect(data.assignments, hasLength(1));
    expect(data.assignments.single.raceName, 'Invitation Race');
    expect(data.assignments.single.scheduledStartLabel, 'Chưa lên lịch');
    expect(data.profileImageUrl, isNull);
  });

  test('returns empty state when no invitation is accepted', () async {
    final repository = _repository(
      invitations: [_invitation(id: 9, status: 'PENDING')],
      profile: _profile(),
    );

    final data = await repository.fetchAssignments();

    expect(data.assignments, isEmpty);
    expect(data.profileImageUrl, 'https://example.test/avatar.png');
  });
}

JockeyHorsesRepository _repository({
  List<JockeyInvitationResponse> invitations = const [],
  List<JockeyRaceResponse> races = const [],
  JockeyProfileResponse? profile,
  bool raceError = false,
  bool profileError = false,
}) {
  return JockeyHorsesRepository(
    invitationService: _InvitationService(invitations),
    raceService: _RaceService(races, shouldThrow: raceError),
    profileService: _ProfileService(profile, shouldThrow: profileError),
  );
}

class _InvitationService extends JockeyInvitationService {
  _InvitationService(this.invitations);

  final List<JockeyInvitationResponse> invitations;

  @override
  Future<List<JockeyInvitationResponse>> getJockeyInvitations() async {
    return invitations;
  }
}

class _RaceService extends JockeyRaceService {
  _RaceService(this.races, {this.shouldThrow = false});

  final List<JockeyRaceResponse> races;
  final bool shouldThrow;

  @override
  Future<List<JockeyRaceResponse>> getJockeyRaces() async {
    if (shouldThrow) throw Exception('race unavailable');
    return races;
  }
}

class _ProfileService extends JockeyProfileService {
  _ProfileService(this.profile, {this.shouldThrow = false});

  final JockeyProfileResponse? profile;
  final bool shouldThrow;

  @override
  Future<JockeyProfileResponse> getMyProfile() async {
    if (shouldThrow || profile == null) throw Exception('profile unavailable');
    return profile!;
  }
}

JockeyInvitationResponse _invitation({
  required int id,
  required String status,
  String? raceName = 'Invitation Race',
  String? tournamentName = 'National Cup',
}) {
  return JockeyInvitationResponse(
    id: id,
    ownerId: 3,
    ownerUsername: 'stable_owner',
    jockeyId: 5,
    horseId: 21,
    horseName: 'Night Wind',
    raceId: 31,
    raceName: raceName,
    tournamentId: 41,
    tournamentName: tournamentName,
    status: status,
    remunerationAmount: 500000,
  );
}

JockeyRaceResponse _race() {
  return JockeyRaceResponse(
    id: '31',
    tournamentId: '41',
    name: 'Race API Name',
    scheduledStartAt: DateTime.parse('2026-07-01T08:00:00'),
    status: 'SCHEDULED',
    participantCount: 8,
  );
}

JockeyProfileResponse _profile() {
  return JockeyProfileResponse.fromJson({
    'id': 11,
    'userId': 5,
    'avatarUrl': 'https://example.test/avatar.png',
    'raceHistory': [
      {
        'tournamentId': 41,
        'tournamentName': 'History Tournament',
        'raceId': 31,
        'raceName': 'History Race',
        'scheduledStartAt': '2026-06-12T10:00:00',
        'horseId': 21,
        'horseName': 'Night Wind',
        'rank': 1,
        'status': 'FINISHED',
        'finishTimeMillis': 73450,
      },
    ],
  });
}
