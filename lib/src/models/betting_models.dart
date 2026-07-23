class BetOption {
  const BetOption({
    required this.participantId,
    required this.horseId,
    required this.horseName,
    this.jockeyId,
    this.jockeyUsername,
    this.gateNumber,
    this.status,
  });

  final String participantId;
  final String horseId;
  final String horseName;
  final String? jockeyId;
  final String? jockeyUsername;
  final int? gateNumber;
  final String? status;

  factory BetOption.fromJson(Map<String, dynamic> json) {
    return BetOption(
      participantId: _id(json['participantId']),
      horseId: _id(json['horseId']),
      horseName: _text(json['horseName'], fallback: 'Chưa cập nhật'),
      jockeyId: _nullableText(json['jockeyId']),
      jockeyUsername: _nullableText(json['jockeyUsername']),
      gateNumber: _nullableInt(json['gateNumber']),
      status: _nullableText(json['status']),
    );
  }
}

class BetMarket {
  const BetMarket({
    required this.id,
    required this.raceId,
    required this.raceName,
    required this.tournamentId,
    required this.tournamentName,
    required this.status,
    required this.minStake,
    required this.maxStake,
    required this.options,
    this.note,
    this.openedAt,
    this.closedAt,
  });

  final String id;
  final String raceId;
  final String raceName;
  final String tournamentId;
  final String tournamentName;
  final String status;
  final num minStake;
  final num maxStake;
  final List<BetOption> options;
  final String? note;
  final DateTime? openedAt;
  final DateTime? closedAt;

  factory BetMarket.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'];
    return BetMarket(
      id: _id(json['id']),
      raceId: _id(json['raceId']),
      raceName: _text(json['raceName'], fallback: 'Cuộc đua'),
      tournamentId: _id(json['tournamentId']),
      tournamentName: _text(json['tournamentName'], fallback: 'Giải đấu'),
      status: _text(json['status'], fallback: 'UNKNOWN').toUpperCase(),
      minStake: _number(json['minStake']),
      maxStake: _number(json['maxStake']),
      note: _nullableText(json['note']),
      openedAt: _date(json['openedAt']),
      closedAt: _date(json['closedAt']),
      options: rawOptions is List
          ? rawOptions
                .whereType<Map<String, dynamic>>()
                .map(BetOption.fromJson)
                .toList(growable: false)
          : const [],
    );
  }

  bool get isOpen => status == 'OPEN';
}

class BetRecord {
  const BetRecord({
    required this.id,
    required this.marketId,
    required this.raceId,
    required this.raceName,
    required this.participantId,
    required this.horseId,
    required this.horseName,
    required this.stakeAmount,
    required this.potentialPayoutAmount,
    required this.status,
    this.winningTaxAmount = 0,
    this.netProfitAmount = 0,
    this.placedAt,
    this.settledAt,
  });

  final String id;
  final String marketId;
  final String raceId;
  final String raceName;
  final String participantId;
  final String horseId;
  final String horseName;
  final num stakeAmount;
  final num potentialPayoutAmount;
  final num winningTaxAmount;
  final num netProfitAmount;
  final String status;
  final DateTime? placedAt;
  final DateTime? settledAt;

  factory BetRecord.fromJson(Map<String, dynamic> json) {
    return BetRecord(
      id: _id(json['id']),
      marketId: _id(json['marketId']),
      raceId: _id(json['raceId']),
      raceName: _text(json['raceName'], fallback: 'Cuộc đua'),
      participantId: _id(json['participantId']),
      horseId: _id(json['horseId']),
      horseName: _text(json['horseName'], fallback: 'Chưa cập nhật'),
      stakeAmount: _number(json['stakeAmount']),
      potentialPayoutAmount: _number(json['potentialPayoutAmount']),
      winningTaxAmount: _number(json['winningTaxAmount']),
      netProfitAmount: _number(json['netProfitAmount']),
      status: _text(json['status'], fallback: 'UNKNOWN').toUpperCase(),
      placedAt: _date(json['placedAt']),
      settledAt: _date(json['settledAt']),
    );
  }
}

String _id(Object? value) => value?.toString().trim() ?? '';

int? _nullableInt(Object? value) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

num _number(Object? value) {
  if (value is num) return value;
  return num.tryParse(value?.toString() ?? '') ?? 0;
}

String _text(Object? value, {required String fallback}) {
  return _nullableText(value) ?? fallback;
}

String? _nullableText(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

DateTime? _date(Object? value) {
  return DateTime.tryParse(value?.toString() ?? '');
}
