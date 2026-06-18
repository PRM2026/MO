class OwnerEligibleHorseTeam {
  const OwnerEligibleHorseTeam({
    required this.invitationId,
    this.horseId,
    this.horseName,
    this.ownerId,
    this.ownerUsername,
    this.jockeyId,
    this.jockeyUsername,
    this.jockeyProfileId,
    this.jockeyFullName,
    this.acceptedAt,
  });

  final int invitationId;
  final int? horseId;
  final String? horseName;
  final int? ownerId;
  final String? ownerUsername;
  final int? jockeyId;
  final String? jockeyUsername;
  final int? jockeyProfileId;
  final String? jockeyFullName;
  final DateTime? acceptedAt;

  factory OwnerEligibleHorseTeam.fromJson(Map<String, dynamic> json) {
    final invitation = _map(json['invitation']);
    final horse = _map(json['horse']);
    final owner = _map(json['owner']);
    final jockey = _map(json['jockey']);
    final profile = _map(json['jockeyProfile']) ?? _map(jockey?['profile']);

    return OwnerEligibleHorseTeam(
      invitationId: _int(json['invitationId'] ?? invitation?['id']) ?? 0,
      horseId: _int(json['horseId'] ?? horse?['id']),
      horseName: _firstString([json['horseName'], horse?['name']]),
      ownerId: _int(json['ownerId'] ?? owner?['id'] ?? owner?['userId']),
      ownerUsername: _firstString([
        json['ownerUsername'],
        owner?['username'],
      ]),
      jockeyId: _int(
        json['jockeyId'] ?? jockey?['id'] ?? jockey?['userId'],
      ),
      jockeyUsername: _firstString([
        json['jockeyUsername'],
        jockey?['username'],
      ]),
      jockeyProfileId: _int(json['jockeyProfileId'] ?? profile?['id']),
      jockeyFullName: _firstString([
        json['jockeyFullName'],
        jockey?['fullName'],
        profile?['fullName'],
        profile?['name'],
      ]),
      acceptedAt: _date(
        json['acceptedAt'] ??
            invitation?['acceptedAt'] ??
            invitation?['respondedAt'],
      ),
    );
  }
}

class OwnerRaceRegistration {
  const OwnerRaceRegistration({
    required this.id,
    required this.statusCode,
    required this.statusLabel,
    this.raceId,
    this.raceName,
    this.tournamentId,
    this.tournamentName,
    this.ownerId,
    this.ownerUsername,
    this.horseId,
    this.horseName,
    this.jockeyId,
    this.jockeyUsername,
    this.jockeyInvitationId,
    this.entryFeeAmount,
    this.ownerNote,
    this.reviewNote,
    this.withdrawNote,
    this.reviewedBy,
    this.reviewedAt,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final int? raceId;
  final String? raceName;
  final int? tournamentId;
  final String? tournamentName;
  final int? ownerId;
  final String? ownerUsername;
  final int? horseId;
  final String? horseName;
  final int? jockeyId;
  final String? jockeyUsername;
  final int? jockeyInvitationId;
  final String statusCode;
  final String statusLabel;
  final num? entryFeeAmount;
  final String? ownerNote;
  final String? reviewNote;
  final String? withdrawNote;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isPending => statusCode == 'PENDING';

  factory OwnerRaceRegistration.fromJson(Map<String, dynamic> json) {
    final race = _map(json['race']);
    final tournament = _map(json['tournament']) ?? _map(race?['tournament']);
    final owner = _map(json['owner']);
    final horse = _map(json['horse']);
    final jockey = _map(json['jockey']);
    final invitation = _map(json['jockeyInvitation']);
    final reviewer = _map(json['reviewer']);
    final status = _status(json['status']);

    return OwnerRaceRegistration(
      id: '${json['id'] ?? ''}',
      raceId: _int(json['raceId'] ?? race?['id']),
      raceName: _firstString([json['raceName'], race?['name']]),
      tournamentId: _int(
        json['tournamentId'] ?? tournament?['id'] ?? race?['tournamentId'],
      ),
      tournamentName: _firstString([
        json['tournamentName'],
        tournament?['name'],
        tournament?['title'],
        race?['tournamentName'],
      ]),
      ownerId: _int(json['ownerId'] ?? owner?['id'] ?? owner?['userId']),
      ownerUsername: _firstString([
        json['ownerUsername'],
        owner?['username'],
      ]),
      horseId: _int(json['horseId'] ?? horse?['id']),
      horseName: _firstString([json['horseName'], horse?['name']]),
      jockeyId: _int(
        json['jockeyId'] ?? jockey?['id'] ?? jockey?['userId'],
      ),
      jockeyUsername: _firstString([
        json['jockeyUsername'],
        jockey?['username'],
      ]),
      jockeyInvitationId: _int(
        json['jockeyInvitationId'] ?? invitation?['id'],
      ),
      statusCode: status,
      statusLabel: ownerRaceRegistrationStatusLabels[status] ?? status,
      entryFeeAmount: _num(
        json['entryFeeAmount'] ?? json['entryFee'] ?? race?['entryFee'],
      ),
      ownerNote: _string(json['ownerNote'] ?? json['note']),
      reviewNote: _string(json['reviewNote']),
      withdrawNote: _string(json['withdrawNote']),
      reviewedBy: _firstString([json['reviewedBy'], reviewer?['username']]),
      reviewedAt: _date(json['reviewedAt']),
      createdAt: _date(json['createdAt']),
      updatedAt: _date(json['updatedAt']),
    );
  }
}

class OwnerRaceRegistrationFormData {
  const OwnerRaceRegistrationFormData({
    this.horseId,
    this.jockeyInvitationId,
    this.note,
  });

  final int? horseId;
  final int? jockeyInvitationId;
  final String? note;

  String? validate() {
    if (horseId == null || horseId! <= 0) return 'Vui lòng chọn ngựa.';
    if (jockeyInvitationId == null || jockeyInvitationId! <= 0) {
      return 'Vui lòng chọn jockey đã nhận lời.';
    }
    if ((note?.trim().length ?? 0) > 1000) {
      return 'Ghi chú tối đa 1000 ký tự.';
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    final body = <String, dynamic>{
      'horseId': horseId,
      'jockeyInvitationId': jockeyInvitationId,
    };
    final value = note?.trim();
    if (value != null && value.isNotEmpty) body['note'] = value;
    return body;
  }
}

class OwnerRaceRegistrationWithdrawData {
  const OwnerRaceRegistrationWithdrawData({this.note});

  final String? note;

  String? validate() {
    if ((note?.trim().length ?? 0) > 1000) {
      return 'Ghi chú rút đăng ký tối đa 1000 ký tự.';
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    final value = note?.trim();
    return value == null || value.isEmpty ? {} : {'note': value};
  }
}

const ownerRaceRegistrationStatusLabels = {
  'PENDING': 'Chờ duyệt',
  'APPROVED': 'Đã duyệt',
  'REJECTED': 'Từ chối',
  'WITHDRAWN': 'Đã rút',
};

String _status(Object? value) => _string(value)?.toUpperCase() ?? 'PENDING';

Map<String, dynamic>? _map(Object? value) =>
    value is Map<String, dynamic> ? value : null;

String? _string(Object? value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

String? _firstString(List<Object?> values) {
  for (final value in values) {
    final text = _string(value);
    if (text != null) return text;
  }
  return null;
}

int? _int(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return value is String ? int.tryParse(value.trim()) : null;
}

num? _num(Object? value) {
  if (value is num) return value;
  return value is String ? num.tryParse(value.trim()) : null;
}

DateTime? _date(Object? value) {
  if (value is! String || value.trim().isEmpty) return null;
  return DateTime.tryParse(value)?.toLocal();
}
