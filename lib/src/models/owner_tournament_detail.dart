import '../utils/image_url_resolver.dart';

class OwnerTournamentDetail {
  const OwnerTournamentDetail({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.bannerUrl,
    required this.status,
    required this.registrationOpenAt,
    required this.registrationCloseAt,
    required this.startAt,
    required this.endAt,
    required this.rules,
    required this.minTeams,
    required this.maxTeams,
    required this.minHorsesPerOwner,
    required this.maxHorsesPerOwner,
    required this.races,
  });

  final String id;
  final String name;
  final String description;
  final String location;
  final String bannerUrl;
  final String status;
  final DateTime? registrationOpenAt;
  final DateTime? registrationCloseAt;
  final DateTime? startAt;
  final DateTime? endAt;
  final String rules;
  final int? minTeams;
  final int? maxTeams;
  final int? minHorsesPerOwner;
  final int? maxHorsesPerOwner;
  final List<OwnerTournamentRace> races;

  factory OwnerTournamentDetail.fromJson(Map<String, dynamic> json) {
    final location = (json['location'] as String?)?.trim() ?? '';
    final provinceName = (json['provinceName'] as String?)?.trim() ?? '';
    final rawRaces = json['races'];

    return OwnerTournamentDetail(
      id: '${json['id'] ?? ''}',
      name: (json['name'] as String?)?.trim() ?? 'Giải đấu',
      description: (json['description'] as String?)?.trim() ?? '',
      location: location.isNotEmpty
          ? location
          : provinceName.isNotEmpty
          ? provinceName
          : 'Chưa cập nhật',
      bannerUrl: ImageUrlResolver.resolve(json['bannerUrl'] as String?),
      status: ((json['status'] as String?) ?? '').toUpperCase(),
      registrationOpenAt: _parseDate(json['registrationOpenAt']),
      registrationCloseAt: _parseDate(json['registrationCloseAt']),
      startAt: _parseDate(json['startAt']),
      endAt: _parseDate(json['endAt']),
      rules: (json['rules'] as String?)?.trim() ?? '',
      minTeams: (json['minTeams'] as num?)?.toInt(),
      maxTeams: (json['maxTeams'] as num?)?.toInt(),
      minHorsesPerOwner: (json['minHorsesPerOwner'] as num?)?.toInt(),
      maxHorsesPerOwner: (json['maxHorsesPerOwner'] as num?)?.toInt(),
      races: rawRaces is List
          ? rawRaces
                .whereType<Map<String, dynamic>>()
                .map(OwnerTournamentRace.fromJson)
                .toList(growable: false)
          : const [],
    );
  }

  String get statusLabel => switch (status) {
    'PUBLISHED' => 'Đã công bố',
    'OPEN_REGISTRATION' => 'Mở đăng ký',
    'REGISTRATION_CLOSED' => 'Đóng đăng ký',
    'SCHEDULED' => 'Đã lên lịch',
    'ONGOING' => 'Đang diễn ra',
    'COMPLETED' => 'Đã kết thúc',
    'CANCELLED' => 'Đã hủy',
    _ => 'Sắp diễn ra',
  };

  String get teamRangeLabel => _rangeLabel(minTeams, maxTeams, 'đội');

  String get horseRangeLabel =>
      _rangeLabel(minHorsesPerOwner, maxHorsesPerOwner, 'ngựa/chủ');
}

class OwnerTournamentRace {
  const OwnerTournamentRace({
    required this.id,
    required this.name,
    required this.distance,
    required this.venue,
    required this.scheduledStartAt,
    required this.scheduledEndAt,
    required this.minParticipants,
    required this.maxParticipants,
    required this.participantCount,
    required this.entryFee,
    required this.status,
    required this.prizes,
  });

  final String id;
  final String name;
  final String distance;
  final String venue;
  final DateTime? scheduledStartAt;
  final DateTime? scheduledEndAt;
  final int? minParticipants;
  final int? maxParticipants;
  final int participantCount;
  final num entryFee;
  final String status;
  final List<OwnerRacePrize> prizes;

  factory OwnerTournamentRace.fromJson(Map<String, dynamic> json) {
    final venueName = (json['venueName'] as String?)?.trim() ?? '';
    final venueAddress = (json['venueAddress'] as String?)?.trim() ?? '';
    final provinceName = (json['provinceName'] as String?)?.trim() ?? '';
    final rawPrizes = json['prizes'];

    return OwnerTournamentRace(
      id: '${json['id'] ?? ''}',
      name: (json['name'] as String?)?.trim() ?? 'Cuộc đua',
      distance: (json['distance'] as String?)?.trim() ?? 'Chưa cập nhật',
      venue: [
        venueName,
        venueAddress,
        provinceName,
      ].where((value) => value.isNotEmpty).join(', '),
      scheduledStartAt: _parseDate(json['scheduledStartAt']),
      scheduledEndAt: _parseDate(json['scheduledEndAt']),
      minParticipants: (json['minParticipants'] as num?)?.toInt(),
      maxParticipants: (json['maxParticipants'] as num?)?.toInt(),
      participantCount: (json['participantCount'] as num?)?.toInt() ?? 0,
      entryFee: (json['entryFee'] as num?) ?? 0,
      status: ((json['status'] as String?) ?? '').toUpperCase(),
      prizes: rawPrizes is List
          ? rawPrizes
                .whereType<Map<String, dynamic>>()
                .map(OwnerRacePrize.fromJson)
                .toList(growable: false)
          : const [],
    );
  }

  String get statusLabel => switch (status) {
    'SCHEDULED' => 'Đã lên lịch',
    'CHECK_IN' => 'Đang check-in',
    'ONGOING' => 'Đang diễn ra',
    'RESULT_CONFIRMED' => 'Đã có kết quả',
    'CANCELLED' => 'Đã hủy',
    _ => 'Sắp diễn ra',
  };

  String get participantLabel {
    if (maxParticipants == null) return '$participantCount người tham gia';
    return '$participantCount/$maxParticipants người tham gia';
  }
}

class OwnerRacePrize {
  const OwnerRacePrize({
    required this.rank,
    required this.amount,
    required this.itemName,
  });

  final int? rank;
  final num amount;
  final String itemName;

  factory OwnerRacePrize.fromJson(Map<String, dynamic> json) {
    return OwnerRacePrize(
      rank: (json['rank'] as num?)?.toInt(),
      amount: (json['amount'] as num?) ?? 0,
      itemName: (json['itemName'] as String?)?.trim() ?? '',
    );
  }
}

DateTime? _parseDate(Object? value) {
  if (value is! String || value.trim().isEmpty) return null;
  return DateTime.tryParse(value)?.toLocal();
}

String _rangeLabel(int? min, int? max, String unit) {
  if (min == null && max == null) return 'Chưa cập nhật';
  if (min == null) return 'Tối đa $max $unit';
  if (max == null) return 'Tối thiểu $min $unit';
  return '$min - $max $unit';
}
