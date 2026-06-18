class JockeyRaceResponse {
  const JockeyRaceResponse({
    required this.id,
    this.tournamentId,
    this.name,
    this.distance,
    this.venueName,
    this.venueAddress,
    this.provinceName,
    this.scheduledStartAt,
    this.scheduledEndAt,
    this.refereeUsername,
    this.status,
    required this.participantCount,
  });

  final String id;
  final String? tournamentId;
  final String? name;
  final String? distance;
  final String? venueName;
  final String? venueAddress;
  final String? provinceName;
  final DateTime? scheduledStartAt;
  final DateTime? scheduledEndAt;
  final String? refereeUsername;
  final String? status;
  final int participantCount;

  factory JockeyRaceResponse.fromJson(Map<String, dynamic> json) {
    return JockeyRaceResponse(
      id: _readString(json['id']) ?? '',
      tournamentId: _readString(json['tournamentId']),
      name: _readString(json['name']),
      distance: _readString(json['distance']),
      venueName: _readString(json['venueName']),
      venueAddress: _readString(json['venueAddress']),
      provinceName: _readString(json['provinceName']),
      scheduledStartAt: _readDate(json['scheduledStartAt']),
      scheduledEndAt: _readDate(json['scheduledEndAt']),
      refereeUsername: _readString(json['refereeUsername']),
      status: _readString(json['status']),
      participantCount: _readInt(json['participantCount']),
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
