class RefereeRaceParticipantResponse {
  const RefereeRaceParticipantResponse({
    this.id,
    this.raceId,
    this.ownerUsername,
    this.horseId,
    this.horseName,
    this.jockeyUsername,
    this.gateNumber,
    this.status,
    this.checkedInAt,
  });

  final int? id;
  final int? raceId;
  final String? ownerUsername;
  final int? horseId;
  final String? horseName;
  final String? jockeyUsername;
  final int? gateNumber;
  final String? status;
  final DateTime? checkedInAt;

  factory RefereeRaceParticipantResponse.fromJson(Map<String, dynamic> json) {
    return RefereeRaceParticipantResponse(
      id: _readInt(json['id']),
      raceId: _readInt(json['raceId']),
      ownerUsername: _readString(json['ownerUsername']),
      horseId: _readInt(json['horseId']),
      horseName: _readString(json['horseName']),
      jockeyUsername: _readString(json['jockeyUsername']),
      gateNumber: _readInt(json['gateNumber']),
      status: _readString(json['status']),
      checkedInAt: _readDate(json['checkedInAt']),
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
