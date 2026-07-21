import '../utils/date_format.dart';
import 'referee_violation_response.dart';

class ViolationRecordItem {
  const ViolationRecordItem({
    required this.id,
    required this.raceLabel,
    required this.horseLabel,
    required this.violationType,
    required this.note,
    required this.timeLabel,
    required this.severity,
    this.penaltyText,
    this.evidenceUrl,
  });

  final int id;
  final String raceLabel;
  final String horseLabel;
  final String violationType;
  final String note;
  final String timeLabel;
  final String severity;
  final String? penaltyText;
  final String? evidenceUrl;

  bool get severityHigh {
    final value = severity.toUpperCase();
    return value == 'MAJOR' || value == 'DISQUALIFICATION';
  }

  String get severityLabel => switch (severity.toUpperCase()) {
    'WARNING' => 'Cảnh cáo',
    'MINOR' => 'Phạt nhẹ',
    'MAJOR' => 'Phạt nặng',
    'DISQUALIFICATION' => 'Loại',
    _ => severity.isEmpty ? 'Chưa xác định' : severity,
  };

  factory ViolationRecordItem.fromApi(RefereeViolationResponse violation) {
    final horseName = violation.horseName?.trim();
    final horseId = violation.horseId;
    final raceName = violation.raceName?.trim();
    final raceId = violation.raceId;

    return ViolationRecordItem(
      id: violation.id ?? 0,
      raceLabel: raceName?.isNotEmpty == true
          ? raceName!
          : raceId == null
          ? 'Cuộc đua'
          : 'Cuộc đua #$raceId',
      horseLabel: horseName?.isNotEmpty == true
          ? horseId == null
                ? horseName!
                : 'H$horseId - $horseName'
          : horseId == null
          ? 'Không rõ ngựa'
          : 'Ngựa #$horseId',
      violationType: _firstNonEmpty([
        violation.typeLabel,
        violation.type,
        'Vi phạm',
      ]),
      note: _firstNonEmpty([violation.description, 'Không có mô tả.']),
      timeLabel: formatDisplayDateTime(
        (violation.occurredAt ?? violation.createdAt)?.toIso8601String(),
        fallback: '—',
      ),
      severity: violation.severity?.trim() ?? '',
      penaltyText: _nullableText(violation.penaltyText),
      evidenceUrl: _nullableText(violation.evidenceUrl),
    );
  }
}

class ViolationsPageData {
  const ViolationsPageData({required this.records, this.profileImageUrl});

  final List<ViolationRecordItem> records;
  final String? profileImageUrl;

  int get totalViolations => records.length;

  factory ViolationsPageData.fromApi({
    required List<RefereeViolationResponse> violations,
    String? profileImageUrl,
  }) {
    final sorted = [...violations]
      ..sort((a, b) {
        final aDate = a.occurredAt ?? a.createdAt;
        final bDate = b.occurredAt ?? b.createdAt;
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return bDate.compareTo(aDate);
      });

    return ViolationsPageData(
      records: sorted.map(ViolationRecordItem.fromApi).toList(growable: false),
      profileImageUrl: profileImageUrl,
    );
  }
}

String _firstNonEmpty(List<String?> values) {
  for (final value in values) {
    final trimmed = value?.trim();
    if (trimmed != null && trimmed.isNotEmpty) return trimmed;
  }
  return '—';
}

String? _nullableText(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}
