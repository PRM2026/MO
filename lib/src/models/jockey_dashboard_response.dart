class JockeyDashboardResponse {
  const JockeyDashboardResponse({
    this.role,
    this.account = const {},
    this.businessSummary = const {},
    this.alerts = const [],
    this.upcoming = const [],
    this.quickLinks = const [],
  });

  final String? role;
  final Map<String, dynamic> account;
  final Map<String, dynamic> businessSummary;
  final List<JockeyDashboardItemResponse> alerts;
  final List<JockeyDashboardItemResponse> upcoming;
  final List<JockeyDashboardQuickLinkResponse> quickLinks;

  factory JockeyDashboardResponse.fromJson(Map<String, dynamic> json) {
    return JockeyDashboardResponse(
      role: _readString(json['role']),
      account: _readMap(json['account']),
      businessSummary: _readMap(json['businessSummary']),
      alerts: _readList(json['alerts'], JockeyDashboardItemResponse.fromJson),
      upcoming: _readList(
        json['upcoming'],
        JockeyDashboardItemResponse.fromJson,
      ),
      quickLinks: _readList(
        json['quickLinks'],
        JockeyDashboardQuickLinkResponse.fromJson,
      ),
    );
  }

  int? get pendingInvitationCount {
    final byStatus = businessSummary['invitationsByStatus'];
    if (byStatus is! Map) return null;
    if (!byStatus.containsKey('PENDING')) return null;
    return _readInt(byStatus['PENDING']);
  }
}

class JockeyDashboardItemResponse {
  const JockeyDashboardItemResponse({
    this.type,
    this.id,
    this.title,
    this.status,
    this.at,
    this.metadata = const {},
  });

  final String? type;
  final int? id;
  final String? title;
  final String? status;
  final DateTime? at;
  final Map<String, dynamic> metadata;

  factory JockeyDashboardItemResponse.fromJson(Map<String, dynamic> json) {
    return JockeyDashboardItemResponse(
      type: _readString(json['type']),
      id: _readInt(json['id']),
      title: _readString(json['title']),
      status: _readString(json['status']),
      at: _readDate(json['at']),
      metadata: _readMap(json['metadata']),
    );
  }
}

class JockeyDashboardQuickLinkResponse {
  const JockeyDashboardQuickLinkResponse({
    required this.label,
    required this.route,
    required this.enabled,
  });

  final String label;
  final String route;
  final bool enabled;

  factory JockeyDashboardQuickLinkResponse.fromJson(Map<String, dynamic> json) {
    return JockeyDashboardQuickLinkResponse(
      label: _readString(json['label']) ?? '',
      route: _readString(json['route']) ?? '',
      enabled: json['enabled'] as bool? ?? true,
    );
  }
}

List<T> _readList<T>(Object? value, T Function(Map<String, dynamic>) mapper) {
  if (value is! List) return const [];
  return value.whereType<Map<String, dynamic>>().map(mapper).toList();
}

Map<String, dynamic> _readMap(Object? value) {
  if (value is! Map) return const {};
  return value.map((key, value) => MapEntry(key.toString(), value));
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

DateTime? _readDate(Object? value) {
  if (value is! String || value.trim().isEmpty) return null;
  return DateTime.tryParse(value);
}
