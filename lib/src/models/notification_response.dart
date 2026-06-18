class NotificationResponse {
  const NotificationResponse({
    required this.id,
    this.recipientId,
    this.recipientUsername,
    this.type,
    required this.title,
    required this.message,
    this.referenceType,
    this.referenceId,
    this.metadataJson,
    this.readAt,
    this.createdAt,
  });

  final String id;
  final String? recipientId;
  final String? recipientUsername;
  final String? type;
  final String title;
  final String message;
  final String? referenceType;
  final String? referenceId;
  final String? metadataJson;
  final DateTime? readAt;
  final DateTime? createdAt;

  bool get isRead => readAt != null;

  NotificationResponse copyWith({
    String? id,
    String? recipientId,
    String? recipientUsername,
    String? type,
    String? title,
    String? message,
    String? referenceType,
    String? referenceId,
    String? metadataJson,
    DateTime? readAt,
    DateTime? createdAt,
  }) {
    return NotificationResponse(
      id: id ?? this.id,
      recipientId: recipientId ?? this.recipientId,
      recipientUsername: recipientUsername ?? this.recipientUsername,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      referenceType: referenceType ?? this.referenceType,
      referenceId: referenceId ?? this.referenceId,
      metadataJson: metadataJson ?? this.metadataJson,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      id: _readString(json['id']) ?? '',
      recipientId: _readString(json['recipientId']),
      recipientUsername: _readString(json['recipientUsername']),
      type: _readString(json['type']),
      title: _readString(json['title']) ?? 'Thông báo',
      message: _readString(json['message']) ?? '',
      referenceType: _readString(json['referenceType']),
      referenceId: _readString(json['referenceId']),
      metadataJson: _readString(json['metadataJson']),
      readAt: _readDate(json['readAt']),
      createdAt: _readDate(json['createdAt']),
    );
  }
}

String? _readString(Object? value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

DateTime? _readDate(Object? value) {
  final raw = _readString(value);
  return raw == null ? null : DateTime.tryParse(raw);
}
