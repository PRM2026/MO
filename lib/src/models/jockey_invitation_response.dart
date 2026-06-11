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
    this.createdAt,
    this.updatedAt,
    this.respondedAt,
    this.cancelledAt,
  });

  final int? id;
  final int? ownerId;
  final String? ownerUsername;
  final int? jockeyId;
  final String? jockeyUsername;
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
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? respondedAt;
  final DateTime? cancelledAt;

  String get idString => id?.toString() ?? '';

  String get statusCode => (status ?? 'PENDING').trim().toUpperCase();

  String get statusLabel =>
      invitationStatusLabels[statusCode] ?? statusCode;

  bool get isPending => statusCode == 'PENDING';

  factory JockeyInvitationResponse.fromJson(Map<String, dynamic> json) {
    return JockeyInvitationResponse(
      id: (json['id'] as num?)?.toInt(),
      ownerId: (json['ownerId'] as num?)?.toInt(),
      ownerUsername: json['ownerUsername'] as String?,
      jockeyId: (json['jockeyId'] as num?)?.toInt(),
      jockeyUsername: json['jockeyUsername'] as String?,
      horseId: (json['horseId'] as num?)?.toInt(),
      horseName: json['horseName'] as String?,
      raceId: (json['raceId'] as num?)?.toInt(),
      raceName: json['raceName'] as String?,
      tournamentId: (json['tournamentId'] as num?)?.toInt(),
      tournamentName: json['tournamentName'] as String?,
      status: json['status'] as String?,
      message: json['message'] as String?,
      responseNote: json['responseNote'] as String?,
      remunerationAmount: json['remunerationAmount'] as num?,
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
      respondedAt: _parseDate(json['respondedAt']),
      cancelledAt: _parseDate(json['cancelledAt']),
    );
  }

  static DateTime? _parseDate(Object? value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  String get _ownerDisplay {
    final name = ownerUsername?.trim();
    if (name != null && name.isNotEmpty) return name;
    if (ownerId != null) return 'Chủ ngựa #$ownerId';
    return 'Chủ ngựa';
  }

  String get _remunerationText => formatVnd(remunerationAmount);

  JockeyInvitationListItem toListItem() {
    return JockeyInvitationListItem(
      id: idString,
      horseName: horseName?.trim().isNotEmpty == true
          ? horseName!.trim()
          : 'Ngựa chưa cập nhật',
      tournamentName: tournamentName?.trim().isNotEmpty == true
          ? tournamentName!.trim()
          : 'Giải đấu chưa cập nhật',
      ownerName: _ownerDisplay,
      raceDate: formatDisplayDate(createdAt?.toIso8601String()),
      baseFee: _remunerationText,
      isNew: isPending,
      statusCode: statusCode,
      statusLabel: statusLabel,
    );
  }

  JockeyInvitationDetail toDetail({String? profileImageUrl}) {
    final raceLabel = raceName?.trim().isNotEmpty == true
        ? raceName!.trim()
        : 'Cuộc đua chưa cập nhật';
    final tournamentLabel = tournamentName?.trim().isNotEmpty == true
        ? tournamentName!.trim()
        : 'Giải đấu chưa cập nhật';

    return JockeyInvitationDetail(
      id: idString,
      horseName: horseName?.trim().isNotEmpty == true
          ? horseName!.trim()
          : 'Ngựa chưa cập nhật',
      horseBreed: horseId != null ? 'Mã ngựa: $horseId' : '—',
      tournamentBadge: tournamentLabel,
      horseImageUrl: '',
      ownerName: _ownerDisplay,
      ownerSubtitle: ownerId != null
          ? 'Chủ ngựa • #$ownerId'
          : 'Chủ ngựa',
      ownerMessage: message?.trim().isNotEmpty == true
          ? message!.trim()
          : 'Chủ ngựa chưa gửi kèm lời nhắn.',
      scheduleWarning: isPending
          ? 'Vui lòng kiểm tra lịch thi đấu trước khi chấp nhận lời mời.'
          : '',
      conflictEventName: '',
      baseFee: _remunerationText,
      prizeShareLabel: 'Thù lao đề xuất',
      prizeShareDescription: 'Số tiền chủ ngựa đề nghị cho lần cưỡi này',
      raceDate: formatDisplayDate(createdAt?.toIso8601String()),
      startTime: '—',
      venue: raceLabel,
      profileImageUrl: profileImageUrl,
      statusCode: statusCode,
      statusLabel: statusLabel,
      responseNote: responseNote?.trim(),
      sentAtLabel: formatDisplayDateTime(createdAt?.toIso8601String()),
    );
  }
}
