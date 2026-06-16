import 'package:http/http.dart' as http;

import '../models/owner_dashboard_data.dart';
import '../models/tournament_list_item.dart';
import '../utils/date_format.dart';
import 'api_client.dart';
import 'auth_storage.dart';

class OwnerDashboardService {
  OwnerDashboardService({
    http.Client? client,
    String? baseUrl,
    AuthStorage? storage,
    ApiClient? apiClient,
  }) : _apiClient =
           apiClient ??
           ApiClient(client: client, baseUrl: baseUrl, storage: storage);

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> getOwnerDashboard() async {
    return _apiClient.getObject('/owner/dashboard', (json) => json);
  }

  Future<List<TournamentListItem>> getTournaments() async {
    return _apiClient.getList(
      '/tournaments',
      TournamentListItem.fromJson,
      authenticated: false,
    );
  }
}

OwnerHeroTournament heroFromTournament(TournamentListItem tournament) {
  return OwnerHeroTournament(
    id: tournament.id,
    title: tournament.title,
    subtitle: '${tournament.homeDateLabel} • ${tournament.location}',
    imageUrl: tournament.imageUrl.isNotEmpty
        ? tournament.imageUrl
        : OwnerDashboardData.sample().hero.imageUrl,
    badgeLabel: tournament.homeStatusBadge,
  );
}

List<OwnerUpcomingRace> racesFromDashboard(Map<String, dynamic> dashboard) {
  final upcoming = dashboard['upcoming'];
  if (upcoming is! List) return const [];

  return upcoming
      .whereType<Map<String, dynamic>>()
      .map(_raceFromDashboardItem)
      .whereType<OwnerUpcomingRace>()
      .toList();
}

OwnerUpcomingRace? _raceFromDashboardItem(Map<String, dynamic> json) {
  final title = (json['title'] as String?)?.trim();
  if (title == null || title.isEmpty) return null;

  final atRaw = json['at'] as String?;
  final at = atRaw != null ? DateTime.tryParse(atRaw)?.toLocal() : null;
  final status = (json['status'] as String?)?.trim().toUpperCase() ?? '';

  final metadata = json['metadata'];
  var venue = '';
  if (metadata is Map<String, dynamic>) {
    venue = (metadata['location'] as String?)?.trim() ?? '';
  }

  final timeLabel = formatDisplayTime(atRaw);
  final detail = venue.isNotEmpty ? '$timeLabel • $venue' : timeLabel;

  return OwnerUpcomingRace(
    id: '${json['id'] ?? title}',
    title: title,
    detail: detail,
    day: at?.day ?? 0,
    monthLabel: at != null ? 'TH${at.month}' : '—',
    statusLabel: _raceStatusLabel(status),
    tone: _raceStatusTone(status),
  );
}

String _raceStatusLabel(String status) {
  return switch (status) {
    'OPEN_REGISTRATION' => 'Mở đăng ký',
    'PUBLISHED' => 'Bán vé',
    'SCHEDULED' => 'Đã lên lịch',
    'REGISTRATION_CLOSED' => 'Đóng đăng ký',
    'ONGOING' => 'Đang diễn ra',
    'DRAFT' => 'Đang chuẩn bị',
    _ => 'Sắp diễn ra',
  };
}

OwnerRaceStatusTone _raceStatusTone(String status) {
  return switch (status) {
    'OPEN_REGISTRATION' => OwnerRaceStatusTone.emerald,
    'PUBLISHED' => OwnerRaceStatusTone.gold,
    _ => OwnerRaceStatusTone.muted,
  };
}
