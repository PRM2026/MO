class RefereeViolationResponse {
  const RefereeViolationResponse({
    this.id,
    this.raceId,
    this.raceName,
    this.horseId,
    this.horseName,
    this.refereeUsername,
    this.type,
    this.typeLabel,
    this.severity,
    this.description,
    this.penaltyText,
    this.occurredAt,
    this.resultAction,
    this.evidenceUrl,
    this.createdAt,
  });

  final int? id;
  final int? raceId;
  final String? raceName;
  final int? horseId;
  final String? horseName;
  final String? refereeUsername;
  final String? type;
  final String? typeLabel;
  final String? severity;
  final String? description;
  final String? penaltyText;
  final DateTime? occurredAt;
  final String? resultAction;
  final String? evidenceUrl;
  final DateTime? createdAt;

  factory RefereeViolationResponse.fromJson(Map<String, dynamic> json) {
    return RefereeViolationResponse(
      id: _readInt(json['id']),
      raceId: _readInt(json['raceId']),
      raceName: _readString(json['raceName']),
      horseId: _readInt(json['horseId']),
      horseName: _readString(json['horseName']),
      refereeUsername: _readString(json['refereeUsername']),
      type: _readString(json['type']),
      typeLabel: _readString(json['typeLabel']),
      severity: _readString(json['severity']),
      description: _readString(json['description']),
      penaltyText: _readString(json['penaltyText']),
      occurredAt: _readDate(json['occurredAt']),
      resultAction: _readString(json['resultAction']),
      evidenceUrl: _readString(json['evidenceUrl']),
      createdAt: _readDate(json['createdAt']),
    );
  }
}

String? _readString(Object? value) {
  if (value == null) return null;
  return value is String ? value : value.toString();
}

int? _readInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return value is String ? int.tryParse(value) : null;
}

DateTime? _readDate(Object? value) {
  if (value is! String || value.trim().isEmpty) return null;
  return DateTime.tryParse(value);
}
