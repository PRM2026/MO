import 'package:flutter_test/flutter_test.dart';
import 'package:horse_racing/src/models/jockey_race_result_response.dart';
import 'package:horse_racing/src/models/owner_tournament_detail.dart';
import 'package:horse_racing/src/models/spectator_models.dart';
import 'package:horse_racing/src/models/tournament_list_item.dart';
import 'package:horse_racing/src/models/user_profile.dart';

void main() {
  group('Spectator models', () {
    test('maps featured event from public tournament item', () {
      final tournament = TournamentListItem.fromJson(const {
        'id': 12,
        'name': 'Summer Cup',
        'provinceName': 'Phu Tho',
        'bannerUrl': '/uploads/tournaments/12.jpg',
        'startAt': '2026-07-15T09:00:00',
        'status': 'open_registration',
      });

      final event = SpectatorFeaturedEvent.fromTournament(tournament);

      expect(event.id, '12');
      expect(event.title, 'Summer Cup');
      expect(event.location, 'Phu Tho');
      expect(event.status, 'OPEN_REGISTRATION');
      expect(event.dateLabel, isNot('--'));
      expect(event.imageUrl, contains('/uploads/tournaments/12.jpg'));
    });

    test('maps race item from json with normalized status and dates', () {
      final race = SpectatorRaceItem.fromJson(const {
        'id': 5,
        'tournamentId': 12,
        'tournamentName': 'Summer Cup',
        'name': 'Qualifier',
        'distance': '1200m',
        'venueName': 'Track A',
        'provinceName': 'Phu Tho',
        'scheduledStartAt': '2026-07-15T09:30:00',
        'scheduledEndAt': '2026-07-15T10:00:00',
        'participantCount': 4,
        'maxParticipants': 12,
        'status': 'SCHEDULED',
        'participantAvatars': ['/uploads/users/1.jpg'],
      });

      expect(race.id, '5');
      expect(race.tournamentId, '12');
      expect(race.tournamentName, 'Summer Cup');
      expect(race.name, 'Qualifier');
      expect(race.status, SpectatorRaceStatus.pending);
      expect(race.statusCode, 'SCHEDULED');
      expect(race.venue, 'Track A, Phu Tho');
      expect(race.time, '09:30');
      expect(race.participantLabel, '4/12 nguoi tham gia');
      expect(race.participantAvatars.single, '/uploads/users/1.jpg');
    });

    test('maps race detail from owner tournament race adapter', () {
      final tournament = OwnerTournamentDetail.fromJson(const {
        'id': 12,
        'name': 'Summer Cup',
        'description': 'National race',
        'location': 'Phu Tho',
        'bannerUrl': '/uploads/tournaments/12.jpg',
        'status': 'OPEN_REGISTRATION',
        'races': [
          {
            'id': 5,
            'name': 'Qualifier',
            'distance': '1200m',
            'venueName': 'Track A',
            'scheduledStartAt': '2026-07-15T09:00:00',
            'participantCount': 4,
            'maxParticipants': 12,
            'entryFee': 500000,
            'status': 'SCHEDULED',
            'prizes': [
              {'rank': 1, 'amount': 10000000, 'itemName': 'Cup'},
            ],
          },
        ],
      });

      final detail = SpectatorRaceDetail.fromTournamentRace(
        tournament.races.single,
        tournament: tournament,
      );

      expect(detail.race.id, '5');
      expect(detail.race.tournamentName, 'Summer Cup');
      expect(detail.race.imageUrl, contains('/uploads/tournaments/12.jpg'));
      expect(detail.prizes.single.rank, 1);
      expect(detail.prizes.single.amount, 10000000);
      expect(detail.hasResults, isFalse);
    });

    test('maps result group from race and race result responses', () {
      final race = SpectatorRaceItem.fromJson(const {
        'id': 5,
        'name': 'Qualifier',
        'distance': '1200m',
        'venueName': 'Track A',
        'scheduledStartAt': '2026-07-15T09:00:00',
        'status': 'RESULT_CONFIRMED',
      });
      final result = JockeyRaceResultResponse.fromJson(const {
        'id': 31,
        'raceId': 5,
        'participantId': 22,
        'ownerId': 4,
        'ownerUsername': 'owner01',
        'horseId': 8,
        'horseName': 'Night Wind',
        'jockeyId': 9,
        'jockeyUsername': 'jockey01',
        'rank': 1,
        'finishTimeMillis': 68123,
        'status': 'FINISHED',
        'jockeyChallengePoints': 10,
        'jockeyPrizeAmount': 500000,
      });

      final group = SpectatorResultGroup.fromRaceResults(
        race: race,
        results: [result],
        verified: true,
      );

      expect(group.raceId, '5');
      expect(group.title, 'Qualifier');
      expect(group.verified, isTrue);
      expect(group.finishers.single.rank, 1);
      expect(group.finishers.single.horseName, 'Night Wind');
      expect(group.finishers.single.jockeyName, 'jockey01');
      expect(group.finishers.single.time, '1:08.123');
    });

    test('keeps optional missing fields empty without fake sample data', () {
      final race = SpectatorRaceItem.fromJson(const {});
      final horse = SpectatorFeaturedHorse.fromJson(const {});
      final profile = SpectatorProfileData.fromJson(const {});

      expect(race.id, '');
      expect(race.name, 'Cuoc dua');
      expect(race.distance, '--');
      expect(race.venue, '--');
      expect(race.status, SpectatorRaceStatus.unknown);
      expect(horse.id, '');
      expect(horse.rider, '--');
      expect(horse.imageUrl, '');
      expect(profile.displayName, 'Khan gia');
      expect(profile.avatarUrl, '');
    });

    test('maps spectator profile from auth user profile', () {
      final profile = SpectatorProfileData.fromUserProfile(
        const UserProfile(
          id: 7,
          username: 'spectator01',
          email: 'spectator@example.test',
          fullName: 'Spectator One',
          role: 'spectator',
          avatarUrl: '/uploads/users/7.jpg',
        ),
      );

      expect(profile.id, 7);
      expect(profile.username, 'spectator01');
      expect(profile.displayName, 'Spectator One');
      expect(profile.role, 'SPECTATOR');
      expect(profile.avatarUrl, contains('/uploads/users/7.jpg'));
    });

    test('maps result group from generic json response', () {
      final group = SpectatorResultGroup.fromJson(const {
        'verified': true,
        'category': 'SPEED_CHALLENGE',
        'race': {
          'id': 9,
          'name': 'Speed Final',
          'distance': '1000m',
          'venueName': 'Track B',
          'scheduledStartAt': '2026-07-16T15:00:00',
        },
        'results': [
          {
            'rank': 1,
            'horseId': 11,
            'horseName': 'Fast Star',
            'jockeyId': 3,
            'jockeyUsername': 'jockey03',
            'ownerId': 2,
            'ownerUsername': 'owner02',
            'finishTimeMillis': 58991,
            'status': 'FINISHED',
          },
        ],
      });

      expect(group.raceId, '9');
      expect(group.title, 'Speed Final');
      expect(group.category, SpectatorResultCategory.speedChallenge);
      expect(group.finishers.single.time, '0:58.991');
      expect(group.showLeaderboardAction, isFalse);
    });
  });
}
