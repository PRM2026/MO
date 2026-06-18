class DepositOrderResponse {
  const DepositOrderResponse({
    required this.id,
    this.userId,
    required this.amount,
    required this.currency,
    this.provider,
    this.status,
    this.depositTarget,
    this.referenceCode,
    this.providerTransactionId,
    this.orderCode,
    this.paymentLinkId,
    this.checkoutUrl,
    this.qrCode,
    this.transferContent,
    this.paidAt,
    this.expiredAt,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String? userId;
  final num amount;
  final String currency;
  final String? provider;
  final String? status;
  final String? depositTarget;
  final String? referenceCode;
  final String? providerTransactionId;
  final String? orderCode;
  final String? paymentLinkId;
  final String? checkoutUrl;
  final String? qrCode;
  final String? transferContent;
  final DateTime? paidAt;
  final DateTime? expiredAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory DepositOrderResponse.fromJson(Map<String, dynamic> json) {
    return DepositOrderResponse(
      id: _readString(json['id']) ?? '',
      userId: _readString(json['userId']),
      amount: _readNum(json['amount']) ?? 0,
      currency: _readString(json['currency']) ?? 'VND',
      provider: _readString(json['provider']),
      status: _readString(json['status']),
      depositTarget: _readString(json['depositTarget']),
      referenceCode: _readString(json['referenceCode']),
      providerTransactionId: _readString(json['providerTransactionId']),
      orderCode: _readString(json['orderCode']),
      paymentLinkId: _readString(json['paymentLinkId']),
      checkoutUrl: _readString(json['checkoutUrl']),
      qrCode: _readString(json['qrCode']),
      transferContent: _readString(json['transferContent']),
      paidAt: _readDate(json['paidAt']),
      expiredAt: _readDate(json['expiredAt']),
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
