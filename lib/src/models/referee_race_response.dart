import 'referee_race_prize_response.dart';

class RefereeRaceResponse {
  const RefereeRaceResponse({
    this.id,
    this.tournamentId,
    this.name,
    this.distance,
    this.venueName,
    this.venueAddress,
    this.provinceName,
    this.refereeUsername,
    this.status,
    this.scheduledStartAt,
    this.scheduledEndAt,
    this.maxParticipants,
    this.participantCount,
    this.resultFinalizedAt,
    this.prizes = const [],
  });

  final int? id;
  final int? tournamentId;
  final String? name;
  final String? distance;
  final String? venueName;
  final String? venueAddress;
  final String? provinceName;
  final String? refereeUsername;
  final String? status;
  final DateTime? scheduledStartAt;
  final DateTime? scheduledEndAt;
  final int? maxParticipants;
  final int? participantCount;
  final DateTime? resultFinalizedAt;
  final List<RefereeRacePrizeResponse> prizes;

  factory RefereeRaceResponse.fromJson(Map<String, dynamic> json) {
    final rawPrizes = json['prizes'];
    return RefereeRaceResponse(
      id: _readInt(json['id']),
      tournamentId: _readInt(json['tournamentId']),
      name: _readString(json['name']),
      distance: _readString(json['distance']),
      venueName: _readString(json['venueName']),
      venueAddress: _readString(json['venueAddress']),
      provinceName: _readString(json['provinceName']),
      refereeUsername: _readString(json['refereeUsername']),
      status: _readString(json['status']),
      scheduledStartAt: _readDate(json['scheduledStartAt']),
      scheduledEndAt: _readDate(json['scheduledEndAt']),
      maxParticipants: _readInt(json['maxParticipants']),
      participantCount: _readInt(json['participantCount']),
      resultFinalizedAt: _readDate(json['resultFinalizedAt']),
      prizes: rawPrizes is List
          ? rawPrizes
              .whereType<Map<String, dynamic>>()
              .map(RefereeRacePrizeResponse.fromJson)
              .toList(growable: false)
          : const [],
    );
  }
}

String? _readString(Object? value) {
  if (value == null) return null;
  if (value is String) return value;
  return value.toString();
}

int? _readInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

DateTime? _readDate(Object? value) {
  if (value is! String || value.trim().isEmpty) return null;
  return DateTime.tryParse(value);
}
