class WalletTransactionResponse {
  const WalletTransactionResponse({
    required this.id,
    this.walletId,
    this.userId,
    this.type,
    this.direction,
    required this.amount,
    this.availableBefore,
    this.availableAfter,
    this.holdBefore,
    this.holdAfter,
    this.status,
    this.referenceType,
    this.referenceId,
    this.idempotencyKey,
    this.metadata,
    this.note,
    this.createdAt,
  });

  final String id;
  final String? walletId;
  final String? userId;
  final String? type;
  final String? direction;
  final num amount;
  final num? availableBefore;
  final num? availableAfter;
  final num? holdBefore;
  final num? holdAfter;
  final String? status;
  final String? referenceType;
  final String? referenceId;
  final String? idempotencyKey;
  final String? metadata;
  final String? note;
  final DateTime? createdAt;

  factory WalletTransactionResponse.fromJson(Map<String, dynamic> json) {
    return WalletTransactionResponse(
      id: _readString(json['id']) ?? '',
      walletId: _readString(json['walletId']),
      userId: _readString(json['userId']),
      type: _readString(json['type']),
      direction: _readString(json['direction']),
      amount: _readNum(json['amount']) ?? 0,
      availableBefore: _readNum(json['availableBefore']),
      availableAfter: _readNum(json['availableAfter']),
      holdBefore: _readNum(json['holdBefore']),
      holdAfter: _readNum(json['holdAfter']),
      status: _readString(json['status']),
      referenceType: _readString(json['referenceType']),
      referenceId: _readString(json['referenceId']),
      idempotencyKey: _readString(json['idempotencyKey']),
      metadata: _readString(json['metadata']),
      note: _readString(json['note']),
      createdAt: _readDate(json['createdAt']),
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
