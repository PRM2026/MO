class RefereeRaceResultResponse {
  const RefereeRaceResultResponse({
    this.id,
    this.raceId,
    this.participantId,
    this.horseName,
    this.jockeyUsername,
    this.rank,
    this.finishTimeMillis,
    this.status,
    this.prizeAmount,
    this.payoutStatus,
    this.note,
    this.finalizedAt,
  });

  final int? id;
  final int? raceId;
  final int? participantId;
  final String? horseName;
  final String? jockeyUsername;
  final int? rank;
  final int? finishTimeMillis;
  final String? status;
  final num? prizeAmount;
  final String? payoutStatus;
  final String? note;
  final DateTime? finalizedAt;

  factory RefereeRaceResultResponse.fromJson(Map<String, dynamic> json) {
    return RefereeRaceResultResponse(
      id: _readInt(json['id']),
      raceId: _readInt(json['raceId']),
      participantId: _readInt(json['participantId']),
      horseName: _readString(json['horseName']),
      jockeyUsername: _readString(json['jockeyUsername']),
      rank: _readInt(json['rank']),
      finishTimeMillis: _readInt(json['finishTimeMillis']),
      status: _readString(json['status']),
      prizeAmount: _readNum(json['prizeAmount']),
      payoutStatus: _readString(json['payoutStatus']),
      note: _readString(json['note']),
      finalizedAt: _readDate(json['finalizedAt']),
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

num? _readNum(Object? value) {
  if (value is num) return value;
  if (value is String) return num.tryParse(value);
  return null;
}

DateTime? _readDate(Object? value) {
  if (value is! String || value.trim().isEmpty) return null;
  return DateTime.tryParse(value);
}
