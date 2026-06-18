class JockeyRaceResponse {
  const JockeyRaceResponse({
    required this.id,
    this.tournamentId,
    this.name,
    this.distance,
    this.minParticipants,
    this.maxParticipants,
    this.venueName,
    this.venueAddress,
    this.provinceName,
    this.scheduledStartAt,
    this.scheduledEndAt,
    this.refereeUsername,
    this.status,
    this.note,
    this.prizes = const [],
    required this.participantCount,
  });

  final String id;
  final String? tournamentId;
  final String? name;
  final String? distance;
  final int? minParticipants;
  final int? maxParticipants;
  final String? venueName;
  final String? venueAddress;
  final String? provinceName;
  final DateTime? scheduledStartAt;
  final DateTime? scheduledEndAt;
  final String? refereeUsername;
  final String? status;
  final String? note;
  final List<JockeyRacePrizeResponse> prizes;
  final int participantCount;

  factory JockeyRaceResponse.fromJson(Map<String, dynamic> json) {
    return JockeyRaceResponse(
      id: _readString(json['id']) ?? '',
      tournamentId: _readString(json['tournamentId']),
      name: _readString(json['name']),
      distance: _readString(json['distance']),
      minParticipants: _readNullableInt(json['minParticipants']),
      maxParticipants: _readNullableInt(json['maxParticipants']),
      venueName: _readString(json['venueName']),
      venueAddress: _readString(json['venueAddress']),
      provinceName: _readString(json['provinceName']),
      scheduledStartAt: _readDate(json['scheduledStartAt']),
      scheduledEndAt: _readDate(json['scheduledEndAt']),
      refereeUsername: _readString(json['refereeUsername']),
      status: _readString(json['status']),
      note: _readString(json['note']),
      prizes: _readList(json['prizes'], JockeyRacePrizeResponse.fromJson),
      participantCount: _readInt(json['participantCount']),
    );
  }
}

class JockeyRacePrizeResponse {
  const JockeyRacePrizeResponse({
    required this.id,
    this.rank,
    required this.amount,
    this.itemName,
    this.note,
    this.createdAt,
  });

  final String id;
  final int? rank;
  final num amount;
  final String? itemName;
  final String? note;
  final DateTime? createdAt;

  factory JockeyRacePrizeResponse.fromJson(Map<String, dynamic> json) {
    return JockeyRacePrizeResponse(
      id: _readString(json['id']) ?? '',
      rank: _readNullableInt(json['rank']),
      amount: _readNum(json['amount']),
      itemName: _readString(json['itemName']),
      note: _readString(json['note']),
      createdAt: _readDate(json['createdAt']),
    );
  }
}

String? _readString(Object? value) {
  if (value == null) return null;
  if (value is String) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
  return value.toString();
}

DateTime? _readDate(Object? value) {
  final raw = _readString(value);
  if (raw == null) return null;
  return DateTime.tryParse(raw);
}

int _readInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim()) ?? 0;
  return 0;
}

int? _readNullableInt(Object? value) {
  if (value == null) return null;
  return _readInt(value);
}

num _readNum(Object? value) {
  if (value is num) return value;
  if (value is String) return num.tryParse(value.trim()) ?? 0;
  return 0;
}

List<T> _readList<T>(Object? value, T Function(Map<String, dynamic>) mapper) {
  if (value is! List) return const [];
  return value.whereType<Map<String, dynamic>>().map(mapper).toList();
}
