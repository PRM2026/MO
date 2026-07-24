import 'package:flutter_test/flutter_test.dart';
import 'package:horse_racing/src/models/betting_models.dart';
import 'package:horse_racing/src/models/jockey_invitation_response.dart';
import 'package:horse_racing/src/models/owner_horse_item.dart';
import 'package:horse_racing/src/models/owner_jockey_invitation.dart';
import 'package:horse_racing/src/models/referee_race_participant_response.dart';
import 'package:horse_racing/src/models/referee_race_response.dart';

void main() {
  const raceId = '6a4e70f4a4c17c9601ace2b8';
  const participantId = '6a5f0f652b89d1c7a8f95f31';
  const horseId = '6a4f31bd5679dc53f139f4db';

  test('spectator betting preserves Railway ObjectIds', () {
    final market = BetMarket.fromJson({
      'id': '6a59c6ac90fe15faabe7d8ef',
      'raceId': raceId,
      'tournamentId': '6a59adf888870865fae696f4',
      'raceName': 'Cuộc đua 1',
      'tournamentName': 'Giải đấu',
      'status': 'OPEN',
      'options': [
        {
          'participantId': participantId,
          'horseId': horseId,
          'horseName': 'Hồng Tỷ',
        },
      ],
    });

    expect(market.raceId, raceId);
    expect(market.options.single.participantId, participantId);
    expect(market.options.single.horseId, horseId);
  });

  test('jockey and owner invitations preserve Railway ObjectIds', () {
    final json = {
      'id': '6a5f0f9a2b89d1c7a8f95fea',
      'ownerId': '6a45ffa2f39ce4024ca749e9',
      'jockeyId': '6a4f2554b11cca01a85a9f8b',
      'horseId': horseId,
      'raceId': raceId,
      'tournamentId': '6a5f0a4c365df345825369fb',
      'status': 'ACCEPTED',
    };

    expect(JockeyInvitationResponse.fromJson(json).raceId, raceId);
    expect(OwnerJockeyInvitation.fromJson(json).horseId, horseId);
  });

  test('owner horse detail preserves Railway owner ObjectId', () {
    const ownerId = '6a45ffa2f39ce4024ca749e9';
    final horse = OwnerHorseDetail.fromJson({
      'id': horseId,
      'ownerId': ownerId,
      'name': 'Hồng Tỷ',
      'status': 'PENDING',
    });

    expect(horse.id, horseId);
    expect(horse.ownerId, ownerId);
  });

  test('referee race operations preserve Railway ObjectIds', () {
    final race = RefereeRaceResponse.fromJson({
      'id': raceId,
      'tournamentId': '6a4e70cfa4c17c9601ace257',
      'name': 'Cuộc đua 1',
    });
    final participant = RefereeRaceParticipantResponse.fromJson({
      'id': participantId,
      'raceId': raceId,
      'horseId': horseId,
    });

    expect(race.id, raceId);
    expect(participant.id, participantId);
    expect(participant.horseId, horseId);
  });
}
