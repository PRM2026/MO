import '../utils/currency_format.dart';
import '../utils/date_format.dart';
import 'jockey_invitation_data.dart';

const invitationStatusLabels = {
  'PENDING': 'Chờ phản hồi',
  'ACCEPTED': 'Đã nhận',
  'REJECTED': 'Từ chối',
  'CANCELLED': 'Đã hủy',
};

class JockeyInvitationResponse {
  const JockeyInvitationResponse({
    this.id,
    this.ownerId,
    this.ownerUsername,
    this.jockeyId,
    this.jockeyUsername,
    this.jockeyProfileId,
    this.horseId,
    this.horseName,
    this.raceId,
    this.raceName,
    this.tournamentId,
    this.tournamentName,
    this.status,
    this.message,
    this.responseNote,
    this.remunerationAmount,
    this.respondedAt,
    this.cancelledAt,
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final int? ownerId;
  final String? ownerUsername;
  final int? jockeyId;
  final String? jockeyUsername;
  final int? jockeyProfileId;
  final int? horseId;
  final String? horseName;
  final int? raceId;
  final String? raceName;
  final int? tournamentId;
  final String? tournamentName;
  final String? status;
  final String? message;
  final String? responseNote;
  final num? remunerationAmount;
  final DateTime? respondedAt;
  final DateTime? cancelledAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get idString => id?.toString() ?? '';
  String get statusCode => (status ?? 'UNKNOWN').trim().toUpperCase();
  String get statusLabel => invitationStatusLabels[statusCode] ?? statusCode;

  factory JockeyInvitationResponse.fromJson(Map<String, dynamic> json) {
    return JockeyInvitationResponse(
      id: _readInt(json['id']),
      ownerId: _readInt(json['ownerId']),
      ownerUsername: _readString(json['ownerUsername']),
      jockeyId: _readInt(json['jockeyId']),
      jockeyUsername: _readString(json['jockeyUsername']),
      jockeyProfileId: _readInt(json['jockeyProfileId']),
      horseId: _readInt(json['horseId']),
      horseName: _readString(json['horseName']),
      raceId: _readInt(json['raceId']),
      raceName: _readString(json['raceName']),
      tournamentId: _readInt(json['tournamentId']),
      tournamentName: _readString(json['tournamentName']),
      status: _readString(json['status']),
      message: _readString(json['message']),
      responseNote: _readString(json['responseNote']),
      remunerationAmount: _readNum(json['remunerationAmount']),
      respondedAt: _readDate(json['respondedAt']),
      cancelledAt: _readDate(json['cancelledAt']),
      createdAt: _readDate(json['createdAt']),
      updatedAt: _readDate(json['updatedAt']),
    );
  }

  JockeyInvitationListItem toListItem() {
    return JockeyInvitationListItem(
      id: idString,
      horseName: _displayName(horseName, 'Ngựa chưa cập nhật'),
      ownerName: _ownerDisplay,
      raceName: _displayName(raceName, 'Chưa gắn cuộc đua'),
      tournamentName: _displayName(tournamentName, 'Chưa gắn giải đấu'),
      remunerationLabel: formatVnd(remunerationAmount),
      createdAtLabel: formatDisplayDateTime(createdAt?.toIso8601String()),
      statusCode: statusCode,
      statusLabel: statusLabel,
    );
  }

  JockeyInvitationDetail toDetail() {
    return JockeyInvitationDetail(
      id: idString,
      ownerName: _ownerDisplay,
      ownerReference: _reference('Chủ ngựa', ownerId),
      jockeyReference: jockeyUsername?.trim().isNotEmpty == true
          ? jockeyUsername!.trim()
          : _reference('Jockey', jockeyId),
      horseName: _displayName(horseName, 'Ngựa chưa cập nhật'),
      horseReference: _reference('Ngựa', horseId),
      raceName: _displayName(raceName, 'Chưa gắn cuộc đua'),
      raceReference: _reference('Cuộc đua', raceId),
      tournamentName: _displayName(tournamentName, 'Chưa gắn giải đấu'),
      tournamentReference: _reference('Giải đấu', tournamentId),
      remunerationLabel: formatVnd(remunerationAmount),
      message: _displayName(message, 'Không có lời nhắn kèm theo.'),
      responseNote: responseNote?.trim() ?? '',
      statusCode: statusCode,
      statusLabel: statusLabel,
      createdAtLabel: formatDisplayDateTime(createdAt?.toIso8601String()),
      updatedAtLabel: formatDisplayDateTime(updatedAt?.toIso8601String()),
      respondedAtLabel: _optionalDate(respondedAt),
      cancelledAtLabel: _optionalDate(cancelledAt),
    );
  }

  String get _ownerDisplay {
    final username = ownerUsername?.trim();
    if (username != null && username.isNotEmpty) return username;
    return _reference('Chủ ngựa', ownerId);
  }

  static String _displayName(String? value, String fallback) {
    final text = value?.trim();
    return text == null || text.isEmpty ? fallback : text;
  }

  static String _reference(String label, int? id) {
    return id == null ? '$label chưa cập nhật' : '$label #$id';
  }

  static String _optionalDate(DateTime? value) {
    if (value == null) return '';
    return formatDisplayDateTime(value.toIso8601String());
  }
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

String? _readString(Object? value) {
  if (value == null) return null;
  return value is String ? value : value.toString();
}

DateTime? _readDate(Object? value) {
  if (value is! String || value.trim().isEmpty) return null;
  return DateTime.tryParse(value);
}
