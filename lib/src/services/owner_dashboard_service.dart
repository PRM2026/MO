import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/owner_dashboard_data.dart';
import '../models/tournament_list_item.dart';
import '../utils/date_format.dart';
import 'auth_storage.dart';
import 'owner_horse_service.dart';

class OwnerDashboardService {
  OwnerDashboardService({
    http.Client? client,
    String? baseUrl,
    AuthStorage? storage,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? ApiConfig.baseUrl,
        _storage = storage ?? AuthStorage();

  final http.Client _client;
  final String _baseUrl;
  final AuthStorage _storage;

  Future<Map<String, dynamic>> getOwnerDashboard() async {
    return _getObject('/owner/dashboard');
  }

  Future<List<TournamentListItem>> getTournaments() async {
    final uri = Uri.parse('$_baseUrl/tournaments');
    final response = await _client.get(
      uri,
      headers: const {'Accept': 'application/json'},
    );

    Map<String, dynamic>? decoded;
    try {
      decoded = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw OwnerApiException('Phản hồi từ máy chủ không hợp lệ.');
    }

    final apiResponse = ApiResponse<List<dynamic>>.fromJson(
      decoded,
      (data) => data as List<dynamic>,
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        apiResponse.success) {
      return (apiResponse.data ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(TournamentListItem.fromJson)
          .toList();
    }

    throw OwnerApiException(
      apiResponse.message.isNotEmpty
          ? apiResponse.message
          : 'Không thể tải giải đấu.',
    );
  }

  Future<Map<String, dynamic>> _getObject(String path) async {
    final token = await _requireToken();
    final uri = Uri.parse('$_baseUrl$path');
    final response = await _client.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    Map<String, dynamic>? decoded;
    try {
      decoded = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw OwnerApiException('Phản hồi từ máy chủ không hợp lệ.');
    }

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      decoded,
      (data) => data as Map<String, dynamic>,
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        apiResponse.success &&
        apiResponse.data != null) {
      return apiResponse.data!;
    }

    throw OwnerApiException(
      apiResponse.message.isNotEmpty
          ? apiResponse.message
          : 'Không thể tải dữ liệu tổng quan.',
    );
  }

  Future<String> _requireToken() async {
    final token = await _storage.getToken();
    if (token == null || token.isEmpty) {
      throw OwnerApiException(
        'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
      );
    }
    return token;
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
