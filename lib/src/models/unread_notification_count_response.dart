class UnreadNotificationCountResponse {
  const UnreadNotificationCountResponse({required this.count});

  final int count;

  factory UnreadNotificationCountResponse.fromJson(Map<String, dynamic> json) {
    return UnreadNotificationCountResponse(count: _readInt(json['count']));
  }
}

int _readInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}
