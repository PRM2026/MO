import '../utils/currency_format.dart';

class JockeyRaceResultResponse {
  const JockeyRaceResultResponse({
    required this.id,
    required this.raceId,
    required this.participantId,
    required this.ownerId,
    this.ownerUsername,
    required this.horseId,
    this.horseName,
    required this.jockeyId,
    this.jockeyUsername,
    required this.rank,
    required this.finishTimeMillis,
    this.status,
    required this.jockeyChallengePoints,
    required this.jockeyPrizeAmount,
    this.payoutStatus,
    this.note,
  });

  final int id;
  final int raceId;
  final int participantId;
  final int ownerId;
  final String? ownerUsername;
  final int horseId;
  final String? horseName;
  final int jockeyId;
  final String? jockeyUsername;
  final int rank;
  final int finishTimeMillis;
  final String? status;
  final int jockeyChallengePoints;
  final num jockeyPrizeAmount;
  final String? payoutStatus;
  final String? note;

  factory JockeyRaceResultResponse.fromJson(Map<String, dynamic> json) {
    return JockeyRaceResultResponse(
      id: _readInt(json['id']),
      raceId: _readInt(json['raceId']),
      participantId: _readInt(json['participantId']),
      ownerId: _readInt(json['ownerId']),
      ownerUsername: _readString(json['ownerUsername']),
      horseId: _readInt(json['horseId']),
      horseName: _readString(json['horseName']),
      jockeyId: _readInt(json['jockeyId']),
      jockeyUsername: _readString(json['jockeyUsername']),
      rank: _readInt(json['rank']),
      finishTimeMillis: _readInt(json['finishTimeMillis']),
      status: _readString(json['status']),
      jockeyChallengePoints: _readInt(json['jockeyChallengePoints']),
      jockeyPrizeAmount: _readNum(json['jockeyPrizeAmount']),
      payoutStatus: _readString(json['payoutStatus']),
      note: _readString(json['note']),
    );
  }

  String get rankLabel => rank > 0 ? 'Hạng $rank' : 'Chưa xếp hạng';

  String get horseLabel => _fallback(horseName, 'Ngựa #$horseId');

  String get ownerLabel => _fallback(ownerUsername, 'Owner #$ownerId');

  String get jockeyLabel => _fallback(jockeyUsername, 'Jockey #$jockeyId');

  String get finishTimeLabel => _formatDuration(finishTimeMillis);

  String get challengePointsLabel => '$jockeyChallengePoints điểm';

  String get jockeyPrizeLabel => formatVnd(jockeyPrizeAmount);

  String get statusLabel => switch ((status ?? '').toUpperCase()) {
    'FINISHED' => 'Hoàn thành',
    'DNF' => 'Không hoàn thành',
    'DISQUALIFIED' => 'Bị loại',
    'ABSENT' => 'Vắng mặt',
    'CHECKED_IN' => 'Đã check-in',
    'REGISTERED' => 'Đã đăng ký',
    _ => status?.trim().isNotEmpty == true ? status!.trim() : 'Chưa cập nhật',
  };

  String get payoutStatusLabel => switch ((payoutStatus ?? '').toUpperCase()) {
    'PAID' => 'Đã thanh toán',
    'PENDING' => 'Đang xử lý',
    'UNPAID' => 'Chưa thanh toán',
    'NOT_ELIGIBLE' => 'Không đủ điều kiện',
    _ =>
      payoutStatus?.trim().isNotEmpty == true
          ? payoutStatus!.trim()
          : 'Chưa cập nhật',
  };
}

class JockeyChallengeStandingResponse {
  const JockeyChallengeStandingResponse({
    required this.jockeyId,
    this.jockeyUsername,
    required this.totalPoints,
    required this.firstPlaces,
    required this.secondPlaces,
    required this.thirdPlaces,
    required this.challengeRank,
    required this.prizeAmount,
    this.payoutStatus,
    this.finalizedAt,
  });

  final int jockeyId;
  final String? jockeyUsername;
  final int totalPoints;
  final int firstPlaces;
  final int secondPlaces;
  final int thirdPlaces;
  final int challengeRank;
  final num prizeAmount;
  final String? payoutStatus;
  final DateTime? finalizedAt;

  factory JockeyChallengeStandingResponse.fromJson(Map<String, dynamic> json) {
    return JockeyChallengeStandingResponse(
      jockeyId: _readInt(json['jockeyId']),
      jockeyUsername: _readString(json['jockeyUsername']),
      totalPoints: _readInt(json['totalPoints']),
      firstPlaces: _readInt(json['firstPlaces']),
      secondPlaces: _readInt(json['secondPlaces']),
      thirdPlaces: _readInt(json['thirdPlaces']),
      challengeRank: _readInt(json['challengeRank']),
      prizeAmount: _readNum(json['prizeAmount']),
      payoutStatus: _readString(json['payoutStatus']),
      finalizedAt: _readDate(json['finalizedAt']),
    );
  }

  String get rankLabel =>
      challengeRank > 0 ? 'Hạng $challengeRank' : 'Chưa xếp hạng';

  String get jockeyLabel => _fallback(jockeyUsername, 'Jockey #$jockeyId');

  String get podiumLabel =>
      '$firstPlaces nhất • $secondPlaces nhì • $thirdPlaces ba';

  String get prizeLabel => formatVnd(prizeAmount);

  String get payoutStatusLabel => switch ((payoutStatus ?? '').toUpperCase()) {
    'PAID' => 'Đã thanh toán',
    'PENDING' => 'Đang xử lý',
    'UNPAID' => 'Chưa thanh toán',
    'NOT_ELIGIBLE' => 'Không đủ điều kiện',
    _ =>
      payoutStatus?.trim().isNotEmpty == true
          ? payoutStatus!.trim()
          : 'Chưa cập nhật',
  };
}

String _formatDuration(int milliseconds) {
  if (milliseconds <= 0) return 'Chưa có thời gian';
  final duration = Duration(milliseconds: milliseconds);
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  final millis = duration.inMilliseconds
      .remainder(1000)
      .toString()
      .padLeft(3, '0');
  return '$minutes:$seconds.$millis';
}

String _fallback(String? value, String fallback) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? fallback : trimmed;
}

String? _readString(Object? value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

int _readInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim()) ?? 0;
  return 0;
}

num _readNum(Object? value) {
  if (value is num) return value;
  if (value is String) return num.tryParse(value.trim()) ?? 0;
  return 0;
}

DateTime? _readDate(Object? value) {
  final raw = _readString(value);
  return raw == null ? null : DateTime.tryParse(raw);
}
