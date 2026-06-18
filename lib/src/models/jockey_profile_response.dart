import '../utils/date_format.dart';

class JockeyProfileResponse {
  const JockeyProfileResponse({
    required this.id,
    required this.userId,
    this.username,
    this.fullName,
    this.licenseNumber,
    required this.experienceYears,
    required this.heightCm,
    required this.weightKg,
    this.bio,
    this.awards,
    this.achievements,
    this.specialties,
    this.avatarUrl,
    this.licenseDocumentUrl,
    this.status,
    this.reviewReason,
    this.reviewedBy,
    this.reviewedAt,
    required this.performance,
    required this.raceHistory,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final int userId;
  final String? username;
  final String? fullName;
  final String? licenseNumber;
  final int experienceYears;
  final num heightCm;
  final num weightKg;
  final String? bio;
  final String? awards;
  final String? achievements;
  final String? specialties;
  final String? avatarUrl;
  final String? licenseDocumentUrl;
  final String? status;
  final String? reviewReason;
  final int? reviewedBy;
  final DateTime? reviewedAt;
  final JockeyProfilePerformance performance;
  final List<JockeyRaceHistoryItem> raceHistory;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory JockeyProfileResponse.fromJson(Map<String, dynamic> json) {
    return JockeyProfileResponse(
      id: _readInt(json['id']),
      userId: _readInt(json['userId']),
      username: _readString(json['username']),
      fullName: _readString(json['fullName']),
      licenseNumber: _readString(json['licenseNumber']),
      experienceYears: _readInt(json['experienceYears']),
      heightCm: _readNum(json['heightCm']),
      weightKg: _readNum(json['weightKg']),
      bio: _readString(json['bio']),
      awards: _readString(json['awards']),
      achievements: _readString(json['achievements']),
      specialties: _readString(json['specialties']),
      avatarUrl: _readString(json['avatarUrl']),
      licenseDocumentUrl: _readString(json['licenseDocumentUrl']),
      status: _readString(json['status']),
      reviewReason: _readString(json['reviewReason']),
      reviewedBy: _readNullableInt(json['reviewedBy']),
      reviewedAt: _readDate(json['reviewedAt']),
      performance: json['performance'] is Map<String, dynamic>
          ? JockeyProfilePerformance.fromJson(
              json['performance'] as Map<String, dynamic>,
            )
          : JockeyProfilePerformance.empty(),
      raceHistory: _readList(
        json['raceHistory'],
        JockeyRaceHistoryItem.fromJson,
      ),
      createdAt: _readDate(json['createdAt']),
      updatedAt: _readDate(json['updatedAt']),
    );
  }

  String get statusCode => (status ?? 'UNKNOWN').trim().toUpperCase();

  String get displayName {
    final name = fullName?.trim();
    if (name != null && name.isNotEmpty) return name;
    final user = username?.trim();
    if (user != null && user.isNotEmpty) return user;
    return 'Jockey';
  }

  String get usernameLabel {
    final value = username?.trim();
    if (value == null || value.isEmpty) return '@jockey';
    return value.startsWith('@') ? value : '@$value';
  }

  String get licenseLabel {
    final value = licenseNumber?.trim();
    if (value == null || value.isEmpty) return 'Chua cap nhat license';
    return value;
  }

  bool get shouldShowReviewReason {
    return (statusCode == 'REJECTED' || statusCode == 'SUSPENDED') &&
        reviewReason?.trim().isNotEmpty == true;
  }

  String get reviewedAtLabel {
    return formatDisplayDateTime(reviewedAt?.toIso8601String());
  }
}

class JockeyProfilePerformance {
  const JockeyProfilePerformance({
    required this.totalRaces,
    required this.wins,
    required this.winRate,
    required this.rankCounts,
  });

  final int totalRaces;
  final int wins;
  final num winRate;
  final Map<String, int> rankCounts;

  factory JockeyProfilePerformance.fromJson(Map<String, dynamic> json) {
    return JockeyProfilePerformance(
      totalRaces: _readInt(json['totalRaces']),
      wins: _readInt(json['wins']),
      winRate: _readNum(json['winRate']),
      rankCounts: _readIntMap(json['rankCounts']),
    );
  }

  factory JockeyProfilePerformance.empty() {
    return const JockeyProfilePerformance(
      totalRaces: 0,
      wins: 0,
      winRate: 0,
      rankCounts: {},
    );
  }

  String get winRateLabel => '${_formatNumber(winRate)}%';
}

class JockeyRaceHistoryItem {
  const JockeyRaceHistoryItem({
    required this.tournamentId,
    this.tournamentName,
    required this.raceId,
    this.raceName,
    this.scheduledStartAt,
    required this.horseId,
    this.horseName,
    required this.rank,
    this.status,
    required this.finishTimeMillis,
    this.finalizedAt,
  });

  final int tournamentId;
  final String? tournamentName;
  final int raceId;
  final String? raceName;
  final DateTime? scheduledStartAt;
  final int horseId;
  final String? horseName;
  final int rank;
  final String? status;
  final int finishTimeMillis;
  final DateTime? finalizedAt;

  factory JockeyRaceHistoryItem.fromJson(Map<String, dynamic> json) {
    return JockeyRaceHistoryItem(
      tournamentId: _readInt(json['tournamentId']),
      tournamentName: _readString(json['tournamentName']),
      raceId: _readInt(json['raceId']),
      raceName: _readString(json['raceName']),
      scheduledStartAt: _readDate(json['scheduledStartAt']),
      horseId: _readInt(json['horseId']),
      horseName: _readString(json['horseName']),
      rank: _readInt(json['rank']),
      status: _readString(json['status']),
      finishTimeMillis: _readInt(json['finishTimeMillis']),
      finalizedAt: _readDate(json['finalizedAt']),
    );
  }

  String get title {
    final value = raceName?.trim();
    if (value != null && value.isNotEmpty) return value;
    return 'Cuoc dua #$raceId';
  }

  String get subtitle {
    final parts = [
      if (tournamentName?.trim().isNotEmpty == true) tournamentName!.trim(),
      if (horseName?.trim().isNotEmpty == true) horseName!.trim(),
      formatDisplayDate(scheduledStartAt?.toIso8601String()),
    ].where((part) => part.isNotEmpty && part != 'â€”').toList();
    return parts.isEmpty ? 'Chua co thong tin' : parts.join(' - ');
  }

  String get rankLabel => rank > 0 ? 'Hang $rank' : 'Chua xep hang';

  String get finishTimeLabel {
    if (finishTimeMillis <= 0) return 'Chua co thoi gian';
    final seconds = finishTimeMillis / 1000;
    return '${seconds.toStringAsFixed(2)}s';
  }
}

List<T> _readList<T>(Object? value, T Function(Map<String, dynamic>) mapper) {
  if (value is! List) return const [];
  return value.whereType<Map<String, dynamic>>().map(mapper).toList();
}

Map<String, int> _readIntMap(Object? value) {
  if (value is! Map) return const {};
  return value.map((key, value) => MapEntry(key.toString(), _readInt(value)));
}

String? _readString(Object? value) {
  if (value == null) return null;
  if (value is String) return value;
  return value.toString();
}

int _readInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

int? _readNullableInt(Object? value) {
  if (value == null) return null;
  return _readInt(value);
}

num _readNum(Object? value) {
  if (value is num) return value;
  if (value is String) return num.tryParse(value) ?? 0;
  return 0;
}

DateTime? _readDate(Object? value) {
  if (value is! String || value.trim().isEmpty) return null;
  return DateTime.tryParse(value);
}

String _formatNumber(num value) {
  if (value % 1 == 0) return value.toInt().toString();
  return value.toStringAsFixed(2);
}
