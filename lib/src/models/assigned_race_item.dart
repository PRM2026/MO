import '../models/referee_race_response.dart';
import '../utils/date_format.dart';

enum AssignedRaceFilter { all, upcoming, live, finished }

enum AssignedRaceStatus { live, ready, pendingResults, upcoming }

class AssignedRaceMeta {
  const AssignedRaceMeta({
    required this.location,
    required this.schedule,
    required this.distance,
    required this.participants,
  });

  final String location;
  final String schedule;
  final String distance;
  final String participants;
}

class AssignedRaceItem {
  const AssignedRaceItem({
    required this.id,
    required this.raceCode,
    required this.title,
    required this.imageUrl,
    required this.status,
    required this.statusLabel,
    required this.beStatus,
    required this.meta,
    required this.actionLabel,
    this.actionFilled = true,
    this.actionEnabled = true,
    this.actionSecondary = false,
    this.dimmed = false,
  });

  final String id;
  final String raceCode;
  final String title;
  final String imageUrl;
  final AssignedRaceStatus status;
  final String statusLabel;
  final String beStatus;
  final AssignedRaceMeta meta;
  final String actionLabel;
  final bool actionFilled;
  final bool actionEnabled;
  final bool actionSecondary;
  final bool dimmed;

  bool matchesFilter(AssignedRaceFilter filter) {
    final status = beStatus.toUpperCase();
    return switch (filter) {
      AssignedRaceFilter.all => true,
      AssignedRaceFilter.upcoming => ![
        'ONGOING',
        'RESULT_CONFIRMED',
        'CANCELLED',
      ].contains(status),
      AssignedRaceFilter.live => status == 'ONGOING',
      AssignedRaceFilter.finished =>
        status == 'RESULT_CONFIRMED' || status == 'CANCELLED',
    };
  }

  static const _defaultRaceImage =
      'https://images.unsplash.com/photo-1553284965-83fd3e82fa5a?auto=format&fit=crop&w=900&q=80';

  factory AssignedRaceItem.fromApi(RefereeRaceResponse race) {
    final beStatus = (race.status ?? '').trim().toUpperCase();
    final uiStatus = _mapUiStatus(beStatus);
    final locationParts = [
      if (race.venueName?.trim().isNotEmpty == true) race.venueName!.trim(),
      if (race.provinceName?.trim().isNotEmpty == true)
        race.provinceName!.trim(),
    ];
    final participantCount = race.participantCount ?? 0;
    final participantsLabel = '$participantCount ngựa';

    final action = _actionForStatus(beStatus);

    return AssignedRaceItem(
      id: race.id ?? race.name ?? '',
      raceCode: race.id != null ? 'Race #${race.id}' : 'Race',
      title: _firstNonEmpty([race.name, 'Cuộc đua']),
      imageUrl: _defaultRaceImage,
      status: uiStatus,
      statusLabel: _statusLabel(beStatus),
      beStatus: beStatus,
      meta: AssignedRaceMeta(
        location: locationParts.isEmpty ? '—' : locationParts.join(', '),
        schedule: _scheduleLabel(race.scheduledStartAt, beStatus),
        distance: race.distance?.trim().isNotEmpty == true
            ? race.distance!.trim()
            : '—',
        participants: participantsLabel,
      ),
      actionLabel: action.label,
      actionFilled: action.filled,
      actionEnabled: action.enabled,
      actionSecondary: action.secondary,
      dimmed: false,
    );
  }

  static AssignedRaceStatus _mapUiStatus(String status) {
    return switch (status) {
      'ONGOING' => AssignedRaceStatus.live,
      'RESULT_CONFIRMED' || 'CANCELLED' => AssignedRaceStatus.pendingResults,
      _ => AssignedRaceStatus.upcoming,
    };
  }

  static String _statusLabel(String status) {
    return switch (status) {
      'ONGOING' => 'Đang diễn ra',
      'RESULT_CONFIRMED' || 'CANCELLED' => 'Đã kết thúc',
      _ => 'Sắp diễn ra',
    };
  }

  static _RaceAction _actionForStatus(String status) {
    return switch (status) {
      'ONGOING' => const _RaceAction(
        label: 'Mở điều hành',
        filled: true,
        enabled: true,
      ),
      'SCHEDULED' => const _RaceAction(
        label: 'Mở check-in',
        filled: true,
        enabled: true,
      ),
      'RESULT_CONFIRMED' => const _RaceAction(
        label: 'Xem kết quả',
        filled: false,
        enabled: true,
        secondary: true,
      ),
      'CANCELLED' => const _RaceAction(
        label: 'Đã hủy',
        filled: false,
        enabled: false,
      ),
      _ => const _RaceAction(label: 'Chưa mở', filled: false, enabled: false),
    };
  }

  static String _scheduleLabel(DateTime? startAt, String status) {
    if (status == 'RESULT_CONFIRMED' || status == 'CANCELLED') {
      return formatDisplayDateTime(startAt?.toIso8601String(), fallback: '—');
    }
    return formatDisplayDateTime(startAt?.toIso8601String(), fallback: '—');
  }
}

class _RaceAction {
  const _RaceAction({
    required this.label,
    this.filled = false,
    this.enabled = false,
    this.secondary = false,
  });

  final String label;
  final bool filled;
  final bool enabled;
  final bool secondary;
}

class AssignedRacesData {
  const AssignedRacesData({
    required this.races,
    this.profileImageUrl,
    this.welcomeMessage =
        'Chào mừng trở lại, hãy kiểm tra các lịch trình điều hành được giao.',
  });

  final List<AssignedRaceItem> races;
  final String? profileImageUrl;
  final String welcomeMessage;

  factory AssignedRacesData.fromApi({
    required List<RefereeRaceResponse> races,
    String? profileImageUrl,
  }) {
    final items = races.map(AssignedRaceItem.fromApi).toList(growable: false);
    final now = DateTime.now();
    final todayCount = races.where((race) {
      final start = race.scheduledStartAt?.toLocal();
      if (start == null) return false;
      return start.year == now.year &&
          start.month == now.month &&
          start.day == now.day;
    }).length;

    final welcomeMessage = todayCount > 0
        ? 'Hôm nay bạn có $todayCount cuộc đua cần điều hành.'
        : 'Chào mừng trở lại, hãy kiểm tra các lịch trình điều hành được giao.';

    return AssignedRacesData(
      races: items,
      profileImageUrl: profileImageUrl,
      welcomeMessage: welcomeMessage,
    );
  }

  static AssignedRacesData sample() {
    return AssignedRacesData(
      profileImageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBviQgH1BI_p3DaJsqvlWVFpKNvTm1rnu5UsamHrMVd6mA_7aezDBQT8rHtkiOfBdZRdEI6Pe8ErPW66QCeyw0fxLtbo7dejY2zjIjTYarkcXwYfAEGxtdhqvR233IM_kLrFMJwG6DLz-cAqQ52NAUMeiQpv6FIekW6q8kZGWuUv_j0NkvwdfT80SmR8kHUgAh1MmW9xedBM-W_cWIsbHTabjFaP_WHtcXkJBCsDxMV1j5RMWHLlNF7dLChXmyjNTvc39tmOAeJ4Hs',
      races: const [
        AssignedRaceItem(
          id: '8',
          raceCode: 'Race #08',
          title: 'Grand Championship 2024',
          imageUrl:
              'https://images.unsplash.com/photo-1553284965-83fd3e82fa5a?auto=format&fit=crop&w=900&q=80',
          status: AssignedRaceStatus.live,
          statusLabel: 'Đang đua',
          beStatus: 'ONGOING',
          meta: AssignedRaceMeta(
            location: 'Phú Thọ, HCM',
            schedule: '14:30 24/05/2026',
            distance: '1200m',
            participants: '8/12 ngựa',
          ),
          actionLabel: 'Mở điều hành',
        ),
      ],
    );
  }
}

String _firstNonEmpty(List<String?> values) {
  for (final value in values) {
    final trimmed = value?.trim();
    if (trimmed != null && trimmed.isNotEmpty) return trimmed;
  }
  return 'Cuộc đua';
}
