import 'package:flutter/material.dart';

import '../constants/referee_colors.dart';
import 'jockey_race_response.dart';

enum JockeyScheduleViewMode { calendar, list }

class JockeyScheduleDateItem {
  const JockeyScheduleDateItem({
    required this.monthLabel,
    required this.day,
    required this.dateKey,
    this.isSelected = false,
  });

  final String monthLabel;
  final int day;
  final String dateKey;
  final bool isSelected;
}

class JockeyRaceScheduleItem {
  const JockeyRaceScheduleItem({
    required this.id,
    this.tournamentId,
    required this.dateKey,
    required this.timeLabel,
    required this.eventName,
    required this.distanceLabel,
    required this.venue,
    required this.refereeLabel,
    required this.participantLabel,
    required this.statusCode,
    required this.statusLabel,
    this.scheduledStartAt,
    this.scheduledEndAt,
  });

  final String id;
  final String? tournamentId;
  final String dateKey;
  final String timeLabel;
  final String eventName;
  final String distanceLabel;
  final String venue;
  final String refereeLabel;
  final String participantLabel;
  final String statusCode;
  final String statusLabel;
  final DateTime? scheduledStartAt;
  final DateTime? scheduledEndAt;

  bool get isUnscheduled => dateKey == JockeyScheduleData.unscheduledDateKey;
}

class JockeyScheduleData {
  const JockeyScheduleData({required this.dates, required this.races});

  static const unscheduledDateKey = 'unscheduled';

  final List<JockeyScheduleDateItem> dates;
  final List<JockeyRaceScheduleItem> races;

  List<JockeyRaceScheduleItem> get unscheduledRaces =>
      races.where((race) => race.isUnscheduled).toList(growable: false);

  static JockeyScheduleData fromResponses(List<JockeyRaceResponse> responses) {
    final races = responses.map(_raceFromResponse).toList(growable: false);
    final seenDateKeys = <String>{};
    final dates = <JockeyScheduleDateItem>[];

    for (final race in races) {
      final start = race.scheduledStartAt;
      if (start == null || !seenDateKeys.add(race.dateKey)) continue;
      dates.add(
        JockeyScheduleDateItem(
          monthLabel: 'Th${start.toLocal().month}',
          day: start.toLocal().day,
          dateKey: race.dateKey,
          isSelected: dates.isEmpty,
        ),
      );
    }

    return JockeyScheduleData(dates: dates, races: races);
  }

  static String statusLabel(String statusCode) {
    return switch (statusCode.trim().toUpperCase()) {
      'SCHEDULED' => 'Đã lên lịch',
      'PENDING' => 'Chờ xử lý',
      'ONGOING' || 'LIVE' => 'Đang diễn ra',
      'COMPLETED' || 'FINISHED' => 'Đã hoàn thành',
      'CANCELLED' || 'CANCELED' => 'Đã hủy',
      'POSTPONED' => 'Tạm hoãn',
      'DRAFT' => 'Bản nháp',
      '' => 'Chưa rõ trạng thái',
      _ => statusCode,
    };
  }

  static Color statusColor(String statusCode) {
    return switch (statusCode.trim().toUpperCase()) {
      'COMPLETED' || 'FINISHED' => RefereeColors.successEmerald,
      'ONGOING' || 'LIVE' => RefereeColors.championshipGold,
      'CANCELLED' || 'CANCELED' => RefereeColors.statusRed,
      'POSTPONED' => RefereeColors.tertiary,
      'PENDING' => RefereeColors.secondary,
      _ => RefereeColors.onSurfaceVariant,
    };
  }
}

JockeyRaceScheduleItem _raceFromResponse(JockeyRaceResponse response) {
  final statusCode = response.status?.trim().toUpperCase() ?? '';

  return JockeyRaceScheduleItem(
    id: response.id,
    tournamentId: response.tournamentId,
    dateKey: _dateKey(response.scheduledStartAt),
    timeLabel: _timeLabel(response.scheduledStartAt, response.scheduledEndAt),
    eventName: _firstNonEmpty([response.name, 'Cuộc đua chưa đặt tên']),
    distanceLabel: _firstNonEmpty([response.distance, 'Chưa có cự ly']),
    venue: _venueLabel(response),
    refereeLabel: _firstNonEmpty([response.refereeUsername, 'Chưa phân công']),
    participantLabel: response.participantCount > 0
        ? '${response.participantCount} người tham gia'
        : 'Chưa có người tham gia',
    statusCode: statusCode,
    statusLabel: JockeyScheduleData.statusLabel(statusCode),
    scheduledStartAt: response.scheduledStartAt,
    scheduledEndAt: response.scheduledEndAt,
  );
}

String _dateKey(DateTime? value) {
  if (value == null) return JockeyScheduleData.unscheduledDateKey;
  final local = value.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '${local.year}-$month-$day';
}

String _timeLabel(DateTime? start, DateTime? end) {
  if (start == null) return 'Chưa lên lịch';
  final startLabel = _clockLabel(start);
  if (end == null) return startLabel;
  return '$startLabel - ${_clockLabel(end)}';
}

String _clockLabel(DateTime value) {
  final local = value.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String _venueLabel(JockeyRaceResponse response) {
  final parts = [
    response.venueName,
    response.provinceName,
  ].where((part) => part != null && part.trim().isNotEmpty).cast<String>();

  final label = parts.join(' • ');
  if (label.isNotEmpty) return label;
  return response.venueAddress?.trim().isNotEmpty == true
      ? response.venueAddress!.trim()
      : 'Chưa có địa điểm';
}

String _firstNonEmpty(List<String?> values) {
  for (final value in values) {
    final trimmed = value?.trim();
    if (trimmed != null && trimmed.isNotEmpty) return trimmed;
  }
  return '';
}
