import '../utils/image_url_resolver.dart';
import 'jockey_race_result_response.dart';
import 'owner_tournament_detail.dart';
import 'tournament_list_item.dart';
import 'user_profile.dart';

const spectatorPlaceholder = '--';

enum SpectatorRaceStatus { open, pending, finished, cancelled, unknown }

enum SpectatorResultCategory {
  all,
  championshipSeries,
  g1Derby,
  speedChallenge,
  recent,
  verified,
  unknown,
}

class SpectatorHomeData {
  const SpectatorHomeData({
    this.featuredEvent,
    this.profile,
    this.scheduleHero,
    this.upcomingRaces = const [],
    this.featuredHorses = const [],
    this.recentResults = const [],
  });

  final SpectatorFeaturedEvent? featuredEvent;
  final SpectatorProfileData? profile;
  final SpectatorScheduleFeatured? scheduleHero;
  final List<SpectatorRaceItem> upcomingRaces;
  final List<SpectatorFeaturedHorse> featuredHorses;
  final List<SpectatorRecentResult> recentResults;

  bool get isEmpty =>
      featuredEvent == null &&
      scheduleHero == null &&
      upcomingRaces.isEmpty &&
      featuredHorses.isEmpty &&
      recentResults.isEmpty;
}

class SpectatorFeaturedEvent {
  const SpectatorFeaturedEvent({
    required this.id,
    required this.title,
    required this.dateLabel,
    required this.location,
    required this.imageUrl,
    required this.status,
    this.startAt,
  });

  final String id;
  final String title;
  final String dateLabel;
  final String location;
  final String imageUrl;
  final String status;
  final DateTime? startAt;

  factory SpectatorFeaturedEvent.fromTournament(TournamentListItem item) {
    return SpectatorFeaturedEvent(
      id: item.id,
      title: _fallback(item.title, 'Giai dau ${item.id}'),
      dateLabel: item.homeDateLabel,
      location: _fallback(item.location, spectatorPlaceholder),
      imageUrl: item.imageUrl,
      status: _normalizeStatus(item.status),
      startAt: item.startAt,
    );
  }

  factory SpectatorFeaturedEvent.fromJson(Map<String, dynamic> json) {
    final id = _readId(json['id']);
    final startAt = _readDate(json['startAt'] ?? json['scheduledStartAt']);
    final rawLocation = _firstString([
      json['location'],
      json['provinceName'],
      json['venueName'],
    ]);

    return SpectatorFeaturedEvent(
      id: id,
      title: _fallback(
        _readString(json['name'] ?? json['title']),
        'Giai dau$id',
      ),
      dateLabel: _formatDate(startAt),
      location: _fallback(rawLocation, spectatorPlaceholder),
      imageUrl: ImageUrlResolver.resolve(
        _readString(json['bannerUrl'] ?? json['imageUrl']),
      ),
      status: _normalizeStatus(json['status']),
      startAt: startAt,
    );
  }
}

class SpectatorScheduleFeatured {
  const SpectatorScheduleFeatured({
    required this.id,
    required this.badge,
    required this.title,
    required this.imageUrl,
  });

  final String id;
  final String badge;
  final String title;
  final String imageUrl;

  factory SpectatorScheduleFeatured.fromRace(SpectatorRaceItem race) {
    return SpectatorScheduleFeatured(
      id: race.id,
      badge: race.statusLabel,
      title: race.name,
      imageUrl: race.imageUrl,
    );
  }
}

class SpectatorRaceItem {
  const SpectatorRaceItem({
    required this.id,
    required this.tournamentId,
    required this.tournamentName,
    required this.name,
    required this.time,
    required this.distance,
    required this.status,
    required this.statusCode,
    required this.venue,
    required this.scheduledStartAt,
    required this.scheduledEndAt,
    required this.participantCount,
    required this.maxParticipants,
    required this.imageUrl,
    this.featured = false,
    this.participantAvatars = const [],
  });

  final String id;
  final String tournamentId;
  final String tournamentName;
  final String name;
  final String time;
  final String distance;
  final SpectatorRaceStatus status;
  final String statusCode;
  final String venue;
  final DateTime? scheduledStartAt;
  final DateTime? scheduledEndAt;
  final int participantCount;
  final int? maxParticipants;
  final String imageUrl;
  final bool featured;
  final List<String> participantAvatars;

  factory SpectatorRaceItem.fromJson(
    Map<String, dynamic> json, {
    String? tournamentId,
    String? tournamentName,
    String? tournamentImageUrl,
  }) {
    final status = _normalizeStatus(json['status']);
    final startAt = _readDate(json['scheduledStartAt'] ?? json['startAt']);
    final venue = _joinNonEmpty([
      _readString(json['venueName']),
      _readString(json['venueAddress']),
      _readString(json['provinceName']),
      _readString(json['venue']),
      _readString(json['location']),
    ]);
    final avatars = _readStringList(json['participantAvatars']);
    final imageUrl = ImageUrlResolver.resolve(
      _readString(json['bannerUrl'] ?? json['imageUrl']) ?? tournamentImageUrl,
    );

    return SpectatorRaceItem(
      id: _readId(json['id']),
      tournamentId: _readId(json['tournamentId'] ?? tournamentId),
      tournamentName: _fallback(
        _readString(json['tournamentName'] ?? tournamentName),
        spectatorPlaceholder,
      ),
      name: _fallback(_readString(json['name'] ?? json['title']), 'Cuoc dua'),
      time: _formatTime(startAt),
      distance: _fallback(_readString(json['distance']), spectatorPlaceholder),
      status: _raceStatus(status),
      statusCode: status,
      venue: _fallback(venue, spectatorPlaceholder),
      scheduledStartAt: startAt,
      scheduledEndAt: _readDate(json['scheduledEndAt'] ?? json['endAt']),
      participantCount: _readInt(json['participantCount']),
      maxParticipants: _readNullableInt(json['maxParticipants']),
      imageUrl: imageUrl,
      featured: _readBool(json['featured']),
      participantAvatars: avatars,
    );
  }

  factory SpectatorRaceItem.fromTournamentRace(
    OwnerTournamentRace race, {
    required OwnerTournamentDetail tournament,
  }) {
    return SpectatorRaceItem.fromJson(
      {
        'id': race.id,
        'name': race.name,
        'distance': race.distance,
        'venue': race.venue,
        'scheduledStartAt': race.scheduledStartAt?.toIso8601String(),
        'scheduledEndAt': race.scheduledEndAt?.toIso8601String(),
        'participantCount': race.participantCount,
        'maxParticipants': race.maxParticipants,
        'status': race.status,
      },
      tournamentId: tournament.id,
      tournamentName: tournament.name,
      tournamentImageUrl: tournament.bannerUrl,
    );
  }

  bool get isUpcoming =>
      status != SpectatorRaceStatus.finished &&
      status != SpectatorRaceStatus.cancelled;

  String get trackInfo => distance == spectatorPlaceholder
      ? spectatorPlaceholder
      : '$distance ${venue == spectatorPlaceholder ? '' : venue}'.trim();

  String get timeBadge {
    final date = scheduledStartAt;
    if (date == null) return spectatorPlaceholder;
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }

  int get extraParticipants => participantCount;

  String get participantLabel {
    if (maxParticipants == null || maxParticipants == 0) {
      return '$participantCount nguoi tham gia';
    }
    return '$participantCount/$maxParticipants nguoi tham gia';
  }

  String get statusLabel {
    return switch (status) {
      SpectatorRaceStatus.open => 'Mo dang ky',
      SpectatorRaceStatus.pending => 'Sap dien ra',
      SpectatorRaceStatus.finished => 'Da ket thuc',
      SpectatorRaceStatus.cancelled => 'Da huy',
      SpectatorRaceStatus.unknown => spectatorPlaceholder,
    };
  }
}

class SpectatorRaceDetail {
  const SpectatorRaceDetail({
    required this.race,
    this.description = '',
    this.rules = '',
    this.prizes = const [],
    this.results = const [],
  });

  final SpectatorRaceItem race;
  final String description;
  final String rules;
  final List<SpectatorRacePrize> prizes;
  final List<SpectatorResultFinisher> results;

  bool get hasResults => results.isNotEmpty;

  factory SpectatorRaceDetail.fromJson(
    Map<String, dynamic> json, {
    String? tournamentId,
    String? tournamentName,
    String? tournamentImageUrl,
  }) {
    return SpectatorRaceDetail(
      race: SpectatorRaceItem.fromJson(
        json,
        tournamentId: tournamentId,
        tournamentName: tournamentName,
        tournamentImageUrl: tournamentImageUrl,
      ),
      description: _readString(json['description']) ?? '',
      rules: _readString(json['rules']) ?? '',
      prizes: _readList(
        json['prizes'],
      ).map(SpectatorRacePrize.fromJson).toList(growable: false),
      results: _readList(
        json['results'],
      ).map(SpectatorResultFinisher.fromJson).toList(growable: false),
    );
  }

  factory SpectatorRaceDetail.fromTournamentRace(
    OwnerTournamentRace race, {
    required OwnerTournamentDetail tournament,
  }) {
    return SpectatorRaceDetail(
      race: SpectatorRaceItem.fromTournamentRace(race, tournament: tournament),
      prizes: race.prizes
          .map(SpectatorRacePrize.fromOwnerPrize)
          .toList(growable: false),
    );
  }
}

class SpectatorRacePrize {
  const SpectatorRacePrize({
    required this.rank,
    required this.amount,
    required this.itemName,
  });

  final int? rank;
  final num amount;
  final String itemName;

  factory SpectatorRacePrize.fromJson(Map<String, dynamic> json) {
    return SpectatorRacePrize(
      rank: _readNullableInt(json['rank']),
      amount: _readNum(json['amount']),
      itemName: _readString(json['itemName'] ?? json['name']) ?? '',
    );
  }

  factory SpectatorRacePrize.fromOwnerPrize(OwnerRacePrize prize) {
    return SpectatorRacePrize(
      rank: prize.rank,
      amount: prize.amount,
      itemName: prize.itemName,
    );
  }
}

class SpectatorFeaturedHorse {
  const SpectatorFeaturedHorse({
    required this.id,
    required this.name,
    required this.rider,
    required this.rank,
    required this.imageUrl,
    this.winRateLabel = spectatorPlaceholder,
  });

  final String id;
  final String name;
  final String rider;
  final int rank;
  final String imageUrl;
  final String winRateLabel;

  factory SpectatorFeaturedHorse.fromJson(Map<String, dynamic> json) {
    return SpectatorFeaturedHorse(
      id: _readId(json['id'] ?? json['horseId']),
      name: _fallback(
        _readString(json['name'] ?? json['horseName']),
        'Ngua ${_readId(json['id'] ?? json['horseId'])}',
      ),
      rider: _fallback(
        _readString(
          json['jockeyName'] ?? json['jockeyUsername'] ?? json['rider'],
        ),
        spectatorPlaceholder,
      ),
      rank: _readInt(json['rank']),
      imageUrl: ImageUrlResolver.resolve(
        _readString(json['imageUrl'] ?? json['horseImageUrl']),
      ),
      winRateLabel: _fallback(
        _readString(json['winRateLabel'] ?? json['winRate']),
        spectatorPlaceholder,
      ),
    );
  }
}

class SpectatorRecentResult {
  const SpectatorRecentResult({
    required this.raceId,
    required this.horseName,
    required this.time,
    required this.eventName,
    this.highlight = false,
  });

  final String raceId;
  final String horseName;
  final String time;
  final String eventName;
  final bool highlight;

  factory SpectatorRecentResult.fromFinisher({
    required String raceId,
    required String eventName,
    required SpectatorResultFinisher finisher,
    bool highlight = false,
  }) {
    return SpectatorRecentResult(
      raceId: raceId,
      horseName: finisher.horseName,
      time: finisher.time,
      eventName: eventName,
      highlight: highlight,
    );
  }
}

class SpectatorResultGroup {
  const SpectatorResultGroup({
    required this.raceId,
    required this.title,
    required this.meta,
    required this.category,
    required this.finishers,
    this.verified = false,
    this.showLeaderboardAction = false,
  });

  final String raceId;
  final String title;
  final String meta;
  final SpectatorResultCategory category;
  final List<SpectatorResultFinisher> finishers;
  final bool verified;
  final bool showLeaderboardAction;

  factory SpectatorResultGroup.fromJson(Map<String, dynamic> json) {
    final race = json['race'];
    final raceMap = race is Map<String, dynamic> ? race : json;
    final startAt = _readDate(
      raceMap['scheduledStartAt'] ?? raceMap['startAt'],
    );
    final distance = _readString(raceMap['distance']) ?? spectatorPlaceholder;
    final venue = _firstString([raceMap['venueName'], raceMap['venue']]);
    final finishers = _readList(
      json['results'] ?? json['finishers'],
    ).map(SpectatorResultFinisher.fromJson).toList(growable: false);

    return SpectatorResultGroup(
      raceId: _readId(raceMap['id'] ?? raceMap['raceId']),
      title: _fallback(
        _readString(raceMap['name'] ?? raceMap['title']),
        'Cuoc dua',
      ),
      meta: _joinNonEmpty([_formatDate(startAt), distance, venue]),
      category: _resultCategory(json['category'] ?? raceMap['category']),
      finishers: finishers,
      verified: _readBool(json['verified']),
      showLeaderboardAction: finishers.length > 3,
    );
  }

  factory SpectatorResultGroup.fromRaceResults({
    required SpectatorRaceItem race,
    required List<JockeyRaceResultResponse> results,
    SpectatorResultCategory category = SpectatorResultCategory.recent,
    bool verified = false,
  }) {
    final finishers = results
        .map(SpectatorResultFinisher.fromJockeyResult)
        .toList(growable: false);

    return SpectatorResultGroup(
      raceId: race.id,
      title: race.name,
      meta: _joinNonEmpty([
        _formatDate(race.scheduledStartAt),
        race.distance,
        race.venue,
      ]),
      category: category,
      finishers: finishers,
      verified: verified,
      showLeaderboardAction: finishers.length > 3,
    );
  }
}

class SpectatorResultFinisher {
  const SpectatorResultFinisher({
    required this.rank,
    required this.horseId,
    required this.horseName,
    required this.jockeyId,
    required this.jockeyName,
    required this.ownerId,
    required this.ownerUsername,
    required this.time,
    required this.status,
    this.note,
    this.delta,
    this.isPersonalBest = false,
  });

  final int rank;
  final int horseId;
  final String horseName;
  final int jockeyId;
  final String jockeyName;
  final int ownerId;
  final String ownerUsername;
  final String time;
  final String status;
  final String? note;
  final String? delta;
  final bool isPersonalBest;

  factory SpectatorResultFinisher.fromJson(Map<String, dynamic> json) {
    final finishMillis = _readInt(json['finishTimeMillis']);
    return SpectatorResultFinisher(
      rank: _readInt(json['rank']),
      horseId: _readInt(json['horseId']),
      horseName: _fallback(
        _readString(json['horseName']),
        'Ngua #${_readInt(json['horseId'])}',
      ),
      jockeyId: _readInt(json['jockeyId']),
      jockeyName: _fallback(
        _readString(json['jockeyUsername'] ?? json['jockeyName']),
        'Jockey #${_readInt(json['jockeyId'])}',
      ),
      ownerId: _readInt(json['ownerId']),
      ownerUsername: _fallback(
        _readString(json['ownerUsername']),
        'Owner #${_readInt(json['ownerId'])}',
      ),
      time: _readString(json['time']) ?? _formatDuration(finishMillis),
      status: _normalizeStatus(json['status']),
      note: _readString(json['note']),
      delta: _readString(json['delta']),
      isPersonalBest: _readBool(json['isPersonalBest']),
    );
  }

  factory SpectatorResultFinisher.fromJockeyResult(
    JockeyRaceResultResponse result,
  ) {
    return SpectatorResultFinisher(
      rank: result.rank,
      horseId: result.horseId,
      horseName: result.horseLabel,
      jockeyId: result.jockeyId,
      jockeyName: result.jockeyLabel,
      ownerId: result.ownerId,
      ownerUsername: result.ownerLabel,
      time: result.finishTimeLabel,
      status: _normalizeStatus(result.status),
      note: result.note,
    );
  }
}

class SpectatorProfileData {
  const SpectatorProfileData({
    this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.role,
    required this.avatarUrl,
    this.phone = '',
  });

  final int? id;
  final String username;
  final String email;
  final String fullName;
  final String role;
  final String avatarUrl;
  final String phone;

  factory SpectatorProfileData.fromJson(Map<String, dynamic> json) {
    return SpectatorProfileData(
      id: _readNullableInt(json['id']),
      username: _readString(json['username']) ?? '',
      email: _readString(json['email']) ?? '',
      fullName: _readString(json['fullName']) ?? '',
      role: _normalizeStatus(json['role'] ?? 'SPECTATOR'),
      avatarUrl: ImageUrlResolver.resolve(_readString(json['avatarUrl'])),
      phone: _readString(json['phone']) ?? '',
    );
  }

  factory SpectatorProfileData.fromUserProfile(UserProfile profile) {
    return SpectatorProfileData(
      id: profile.id,
      username: profile.username ?? '',
      email: profile.email ?? '',
      fullName: profile.fullName ?? '',
      role: _normalizeStatus(profile.role ?? 'SPECTATOR'),
      avatarUrl: ImageUrlResolver.resolve(profile.avatarUrl),
    );
  }

  String get displayName {
    final name = fullName.trim();
    if (name.isNotEmpty) return name;
    final user = username.trim();
    if (user.isNotEmpty) return user;
    return 'Khan gia';
  }
}

String _readId(Object? value) {
  final text = _readString(value);
  if (text == null || text.isEmpty) return '';
  return text;
}

String? _readString(Object? value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

String _fallback(String? value, String fallback) {
  final text = value?.trim();
  return text == null || text.isEmpty ? fallback : text;
}

String _normalizeStatus(Object? value) {
  return (_readString(value) ?? '').toUpperCase();
}

int _readInt(Object? value) {
  return _readNullableInt(value) ?? 0;
}

int? _readNullableInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim());
  return null;
}

num _readNum(Object? value) {
  if (value is num) return value;
  if (value is String) return num.tryParse(value.trim()) ?? 0;
  return 0;
}

bool _readBool(Object? value) {
  if (value is bool) return value;
  if (value is String) return value.toLowerCase() == 'true';
  return false;
}

DateTime? _readDate(Object? value) {
  final text = _readString(value);
  if (text == null) return null;
  return DateTime.tryParse(text)?.toLocal();
}

List<Map<String, dynamic>> _readList(Object? value) {
  if (value is! List) return const [];
  return value.whereType<Map<String, dynamic>>().toList(growable: false);
}

List<String> _readStringList(Object? value) {
  if (value is! List) return const [];
  return value.map(_readString).whereType<String>().toList(growable: false);
}

String? _firstString(List<Object?> values) {
  for (final value in values) {
    final text = _readString(value);
    if (text != null) return text;
  }
  return null;
}

String _joinNonEmpty(List<String?> values) {
  return values
      .whereType<String>()
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty && value != spectatorPlaceholder)
      .join(', ');
}

String _formatDate(DateTime? date) {
  if (date == null) return spectatorPlaceholder;
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}

String _formatTime(DateTime? date) {
  if (date == null) return spectatorPlaceholder;
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String _formatDuration(int milliseconds) {
  if (milliseconds <= 0) return spectatorPlaceholder;
  final duration = Duration(milliseconds: milliseconds);
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  final millis = duration.inMilliseconds
      .remainder(1000)
      .toString()
      .padLeft(3, '0');
  return '$minutes:$seconds.$millis';
}

SpectatorRaceStatus _raceStatus(String status) {
  return switch (status) {
    'OPEN_REGISTRATION' || 'PUBLISHED' => SpectatorRaceStatus.open,
    'COMPLETED' ||
    'RESULT_CONFIRMED' ||
    'FINISHED' => SpectatorRaceStatus.finished,
    'CANCELLED' => SpectatorRaceStatus.cancelled,
    'SCHEDULED' ||
    'ONGOING' ||
    'CHECK_IN' ||
    'REGISTRATION_CLOSED' => SpectatorRaceStatus.pending,
    _ => SpectatorRaceStatus.unknown,
  };
}

SpectatorResultCategory _resultCategory(Object? value) {
  final text = _normalizeStatus(value);
  return switch (text) {
    'CHAMPIONSHIP_SERIES' => SpectatorResultCategory.championshipSeries,
    'G1_DERBY' => SpectatorResultCategory.g1Derby,
    'SPEED_CHALLENGE' => SpectatorResultCategory.speedChallenge,
    'RECENT' => SpectatorResultCategory.recent,
    'VERIFIED' => SpectatorResultCategory.verified,
    'ALL' => SpectatorResultCategory.all,
    _ => SpectatorResultCategory.unknown,
  };
}
