import 'jockey_dashboard_response.dart';

class RefereeDashboardResponse {
  const RefereeDashboardResponse({
    this.account = const {},
    this.wallet = const {},
    this.businessSummary = const {},
    this.alerts = const [],
    this.upcoming = const [],
    this.quickLinks = const [],
  });

  final Map<String, dynamic> account;
  final Map<String, dynamic> wallet;
  final Map<String, dynamic> businessSummary;
  final List<JockeyDashboardItemResponse> alerts;
  final List<JockeyDashboardItemResponse> upcoming;
  final List<JockeyDashboardQuickLinkResponse> quickLinks;

  factory RefereeDashboardResponse.fromJson(Map<String, dynamic> json) {
    return RefereeDashboardResponse(
      account: _readMap(json['account']),
      wallet: _readMap(json['wallet']),
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

  int summaryInt(String key) => _readInt(businessSummary[key]) ?? 0;

  num get walletAvailableBalance => _readNum(wallet['availableBalance']);
}

List<T> _readList<T>(Object? value, T Function(Map<String, dynamic>) mapper) {
  if (value is! List) return const [];
  return value.whereType<Map<String, dynamic>>().map(mapper).toList();
}

Map<String, dynamic> _readMap(Object? value) {
  if (value is! Map) return const {};
  return value.map((key, value) => MapEntry(key.toString(), value));
}

int? _readInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

num _readNum(Object? value) {
  if (value is num) return value;
  if (value is String) return num.tryParse(value) ?? 0;
  return 0;
}
