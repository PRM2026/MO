class RefereeRaceResponse {
  const RefereeRaceResponse({
    this.id,
    this.name,
    this.distance,
    this.venueName,
    this.provinceName,
    this.refereeUsername,
    this.status,
    this.scheduledStartAt,
    this.scheduledEndAt,
    this.participantCount,
  });

  final int? id;
  final String? name;
  final String? distance;
  final String? venueName;
  final String? provinceName;
  final String? refereeUsername;
  final String? status;
  final DateTime? scheduledStartAt;
  final DateTime? scheduledEndAt;
  final int? participantCount;

  factory RefereeRaceResponse.fromJson(Map<String, dynamic> json) {
    return RefereeRaceResponse(
      id: _readInt(json['id']),
      name: _readString(json['name']),
      distance: _readString(json['distance']),
      venueName: _readString(json['venueName']),
      provinceName: _readString(json['provinceName']),
      refereeUsername: _readString(json['refereeUsername']),
      status: _readString(json['status']),
      scheduledStartAt: _readDate(json['scheduledStartAt']),
      scheduledEndAt: _readDate(json['scheduledEndAt']),
      participantCount: _readInt(json['participantCount']),
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
