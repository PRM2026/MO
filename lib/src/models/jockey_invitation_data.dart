enum JockeyInvitationFilter {
  all('Tất cả', null),
  pending('Chờ phản hồi', 'PENDING'),
  accepted('Đã nhận', 'ACCEPTED'),
  rejected('Từ chối', 'REJECTED'),
  cancelled('Đã hủy', 'CANCELLED');

  const JockeyInvitationFilter(this.label, this.statusCode);

  final String label;
  final String? statusCode;
}

class JockeyInvitationListItem {
  const JockeyInvitationListItem({
    required this.id,
    required this.horseName,
    required this.ownerName,
    required this.raceName,
    required this.tournamentName,
    required this.remunerationLabel,
    required this.createdAtLabel,
    required this.statusCode,
    required this.statusLabel,
  });

  final String id;
  final String horseName;
  final String ownerName;
  final String raceName;
  final String tournamentName;
  final String remunerationLabel;
  final String createdAtLabel;
  final String statusCode;
  final String statusLabel;
}

class JockeyInvitationDetail {
  const JockeyInvitationDetail({
    required this.id,
    required this.ownerName,
    required this.ownerReference,
    required this.jockeyReference,
    required this.horseName,
    required this.horseReference,
    required this.raceName,
    required this.raceReference,
    required this.tournamentName,
    required this.tournamentReference,
    required this.remunerationLabel,
    required this.message,
    required this.responseNote,
    required this.statusCode,
    required this.statusLabel,
    required this.createdAtLabel,
    required this.updatedAtLabel,
    required this.respondedAtLabel,
    required this.cancelledAtLabel,
  });

  final String id;
  final String ownerName;
  final String ownerReference;
  final String jockeyReference;
  final String horseName;
  final String horseReference;
  final String raceName;
  final String raceReference;
  final String tournamentName;
  final String tournamentReference;
  final String remunerationLabel;
  final String message;
  final String responseNote;
  final String statusCode;
  final String statusLabel;
  final String createdAtLabel;
  final String updatedAtLabel;
  final String respondedAtLabel;
  final String cancelledAtLabel;

  bool get hasResponseNote => responseNote.isNotEmpty;
  bool get hasRespondedAt => respondedAtLabel.isNotEmpty;
  bool get hasCancelledAt => cancelledAtLabel.isNotEmpty;
}
