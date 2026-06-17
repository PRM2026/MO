class JockeyPerformanceResponse {
  const JockeyPerformanceResponse({
    required this.jockeyId,
    required this.raceCount,
    required this.completedRaceCount,
    required this.firstPlaces,
    required this.secondPlaces,
    required this.thirdPlaces,
    required this.totalJockeyPayout,
    required this.totalPrizePayout,
    required this.recentRaces,
  });

  final int jockeyId;
  final int raceCount;
  final int completedRaceCount;
  final int firstPlaces;
  final int secondPlaces;
  final int thirdPlaces;
  final num totalJockeyPayout;
  final num totalPrizePayout;
  final List<JockeyPerformanceRaceResponse> recentRaces;

  factory JockeyPerformanceResponse.fromJson(Map<String, dynamic> json) {
    return JockeyPerformanceResponse(
      jockeyId: _readInt(json['jockeyId']),
      raceCount: _readInt(json['raceCount']),
      completedRaceCount: _readInt(json['completedRaceCount']),
      firstPlaces: _readInt(json['firstPlaces']),
      secondPlaces: _readInt(json['secondPlaces']),
      thirdPlaces: _readInt(json['thirdPlaces']),
      totalJockeyPayout: _readNum(json['totalJockeyPayout']),
      totalPrizePayout: _readNum(json['totalPrizePayout']),
      recentRaces: _readList(
        json['recentRaces'],
        JockeyPerformanceRaceResponse.fromJson,
      ),
    );
  }
}

class JockeyPerformanceRaceResponse {
  const JockeyPerformanceRaceResponse({
    required this.id,
    this.name,
    this.distance,
    this.venueName,
    this.provinceName,
    this.scheduledStartAt,
    this.status,
    required this.participantCount,
  });

  final int id;
  final String? name;
  final String? distance;
  final String? venueName;
  final String? provinceName;
  final DateTime? scheduledStartAt;
  final String? status;
  final int participantCount;

  factory JockeyPerformanceRaceResponse.fromJson(Map<String, dynamic> json) {
    return JockeyPerformanceRaceResponse(
      id: _readInt(json['id']),
      name: _readString(json['name']),
      distance: _readString(json['distance']),
      venueName: _readString(json['venueName']),
      provinceName: _readString(json['provinceName']),
      scheduledStartAt: _readDate(json['scheduledStartAt']),
      status: _readString(json['status']),
      participantCount: _readInt(json['participantCount']),
    );
  }
}

List<T> _readList<T>(Object? value, T Function(Map<String, dynamic>) mapper) {
  if (value is! List) return const [];
  return value.whereType<Map<String, dynamic>>().map(mapper).toList();
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

num _readNum(Object? value) {
  if (value is num) return value;
  if (value is String) return num.tryParse(value) ?? 0;
  return 0;
}

DateTime? _readDate(Object? value) {
  if (value is! String || value.trim().isEmpty) return null;
  return DateTime.tryParse(value);
}
