import '../utils/currency_format.dart';

class JockeyHorseAssignmentItem {
  const JockeyHorseAssignmentItem({
    required this.invitationId,
    this.horseId,
    required this.horseName,
    required this.ownerUsername,
    this.raceId,
    required this.raceName,
    this.tournamentId,
    required this.tournamentName,
    required this.assignmentStatusCode,
    required this.raceStatusCode,
    required this.remunerationAmount,
    this.scheduledStartAt,
    required this.hasRaceDetail,
  });

  final String invitationId;
  final Object? horseId;
  final String horseName;
  final String ownerUsername;
  final String? raceId;
  final String raceName;
  final String? tournamentId;
  final String tournamentName;
  final String assignmentStatusCode;
  final String raceStatusCode;
  final num remunerationAmount;
  final DateTime? scheduledStartAt;
  final bool hasRaceDetail;

  String get assignmentStatusLabel => switch (assignmentStatusCode) {
    'ACCEPTED' => 'Đã nhận',
    _ =>
      assignmentStatusCode.isEmpty
          ? 'Chưa rõ trạng thái'
          : assignmentStatusCode,
  };

  String get raceStatusLabel => switch (raceStatusCode) {
    'PUBLISHED' => 'Đã công bố',
    'OPEN_REGISTRATION' => 'Mở đăng ký',
    'REGISTRATION_CLOSED' => 'Đóng đăng ký',
    'SCHEDULED' => 'Đã lên lịch',
    'ONGOING' => 'Đang diễn ra',
    'RESULT_CONFIRMED' => 'Đã có kết quả',
    'CANCELLED' => 'Đã hủy',
    'FINISHED' => 'Hoàn thành',
    'DNF' => 'Không hoàn thành',
    'DISQUALIFIED' => 'Bị loại',
    'ABSENT' => 'Vắng mặt',
    _ => raceStatusCode.isEmpty ? 'Chưa cập nhật' : raceStatusCode,
  };

  String get remunerationLabel => formatVnd(remunerationAmount);

  String get scheduledStartLabel {
    final value = scheduledStartAt?.toLocal();
    if (value == null) return 'Chưa lên lịch';
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day/$month/${value.year} $hour:$minute';
  }
}

class JockeyHorseAssignmentsData {
  const JockeyHorseAssignmentsData({
    required this.assignments,
    this.profileImageUrl,
  });

  final List<JockeyHorseAssignmentItem> assignments;
  final String? profileImageUrl;
}
