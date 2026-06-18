class WalletResponse {
  const WalletResponse({
    required this.id,
    this.ownerType,
    this.userId,
    required this.currency,
    required this.availableBalance,
    required this.holdBalance,
    required this.totalBalance,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String? ownerType;
  final String? userId;
  final String currency;
  final num availableBalance;
  final num holdBalance;
  final num totalBalance;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isActive => status == 'ACTIVE';

  factory WalletResponse.fromJson(Map<String, dynamic> json) {
    final available = _readNum(json['availableBalance']) ?? 0;
    final hold = _readNum(json['holdBalance']) ?? 0;
    return WalletResponse(
      id: _readString(json['id']) ?? '',
      ownerType: _readString(json['ownerType']),
      userId: _readString(json['userId']),
      currency: _readString(json['currency']) ?? 'VND',
      availableBalance: available,
      holdBalance: hold,
      totalBalance: _readNum(json['totalBalance']) ?? available + hold,
      status: _readString(json['status']),
      createdAt: _readDate(json['createdAt']),
      updatedAt: _readDate(json['updatedAt']),
    );
  }
}

String? _readString(Object? value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

num? _readNum(Object? value) {
  if (value is num) return value;
  if (value is String) return num.tryParse(value.trim());
  return null;
}

DateTime? _readDate(Object? value) {
  final raw = _readString(value);
  return raw == null ? null : DateTime.tryParse(raw);
}
