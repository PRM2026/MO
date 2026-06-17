class RefereeRacePrizeResponse {
  const RefereeRacePrizeResponse({
    this.id,
    this.rank,
    this.amount,
    this.itemName,
    this.note,
  });

  final int? id;
  final int? rank;
  final num? amount;
  final String? itemName;
  final String? note;

  factory RefereeRacePrizeResponse.fromJson(Map<String, dynamic> json) {
    return RefereeRacePrizeResponse(
      id: _readInt(json['id']),
      rank: _readInt(json['rank']),
      amount: _readNum(json['amount']),
      itemName: _readString(json['itemName']),
      note: _readString(json['note']),
    );
  }
}

String? _readString(Object? value) {
  if (value == null) return null;
  if (value is String) return value;
  return value.toString();
}

int? _readInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

num? _readNum(Object? value) {
  if (value is num) return value;
  if (value is String) return num.tryParse(value);
  return null;
}
