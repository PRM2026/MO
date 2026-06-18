class WithdrawalResponse {
  const WithdrawalResponse({
    required this.id,
    this.userId,
    required this.amount,
    required this.currency,
    this.status,
    required this.bankName,
    required this.bankAccountNumber,
    required this.bankAccountName,
    this.reason,
    this.adminNote,
    this.approvedBy,
    this.rejectedBy,
    this.paidBy,
    this.approvedAt,
    this.rejectedAt,
    this.paidAt,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String? userId;
  final num amount;
  final String currency;
  final String? status;
  final String bankName;
  final String bankAccountNumber;
  final String bankAccountName;
  final String? reason;
  final String? adminNote;
  final String? approvedBy;
  final String? rejectedBy;
  final String? paidBy;
  final DateTime? approvedAt;
  final DateTime? rejectedAt;
  final DateTime? paidAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory WithdrawalResponse.fromJson(Map<String, dynamic> json) {
    return WithdrawalResponse(
      id: _readString(json['id']) ?? '',
      userId: _readString(json['userId']),
      amount: _readNum(json['amount']) ?? 0,
      currency: _readString(json['currency']) ?? 'VND',
      status: _readString(json['status']),
      bankName: _readString(json['bankName']) ?? '',
      bankAccountNumber: _readString(json['bankAccountNumber']) ?? '',
      bankAccountName: _readString(json['bankAccountName']) ?? '',
      reason: _readString(json['reason']),
      adminNote: _readString(json['adminNote']),
      approvedBy: _readString(json['approvedBy']),
      rejectedBy: _readString(json['rejectedBy']),
      paidBy: _readString(json['paidBy']),
      approvedAt: _readDate(json['approvedAt']),
      rejectedAt: _readDate(json['rejectedAt']),
      paidAt: _readDate(json['paidAt']),
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
