class JockeyInvitationListItem {
  const JockeyInvitationListItem({
    required this.id,
    required this.horseName,
    required this.tournamentName,
    required this.ownerName,
    required this.raceDate,
    required this.baseFee,
    this.horseImageUrl,
    this.isNew = false,
    this.statusCode = 'PENDING',
    this.statusLabel = 'Chờ phản hồi',
  });

  final String id;
  final String horseName;
  final String tournamentName;
  final String ownerName;
  final String raceDate;
  final String baseFee;
  final String? horseImageUrl;
  final bool isNew;
  final String statusCode;
  final String statusLabel;

  bool get isPending => statusCode == 'PENDING';
}

class JockeyInvitationDetail {
  const JockeyInvitationDetail({
    required this.id,
    required this.horseName,
    required this.horseBreed,
    required this.tournamentBadge,
    required this.horseImageUrl,
    required this.ownerName,
    required this.ownerSubtitle,
    required this.ownerMessage,
    required this.scheduleWarning,
    required this.conflictEventName,
    required this.baseFee,
    required this.prizeShareLabel,
    required this.prizeShareDescription,
    required this.raceDate,
    required this.startTime,
    required this.venue,
    this.profileImageUrl,
    this.statusCode = 'PENDING',
    this.statusLabel = 'Chờ phản hồi',
    this.responseNote,
    this.sentAtLabel,
  });

  final String id;
  final String horseName;
  final String horseBreed;
  final String tournamentBadge;
  final String horseImageUrl;
  final String ownerName;
  final String ownerSubtitle;
  final String ownerMessage;
  final String scheduleWarning;
  final String conflictEventName;
  final String baseFee;
  final String prizeShareLabel;
  final String prizeShareDescription;
  final String raceDate;
  final String startTime;
  final String venue;
  final String? profileImageUrl;
  final String statusCode;
  final String statusLabel;
  final String? responseNote;
  final String? sentAtLabel;

  bool get isPending => statusCode == 'PENDING';
}
