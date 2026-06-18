String formatRaceFinishTime(int? millis, {String fallback = '—'}) {
  if (millis == null) return fallback;
  final totalSeconds = millis / 1000.0;
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds - minutes * 60;
  final secStr = seconds.toStringAsFixed(2).padLeft(5, '0');
  return '${minutes.toString().padLeft(2, '0')}:$secStr';
}

String formatRaceGap(int? millis, int? leaderMillis) {
  if (millis == null || leaderMillis == null || millis <= leaderMillis) {
    return '—';
  }
  final diffSec = (millis - leaderMillis) / 1000.0;
  return '+${diffSec.toStringAsFixed(2)}s';
}

String participantStatusLabel(String? status) {
  return switch (status) {
    'FINISHED' => 'Về đích',
    'DNF' => 'Không hoàn thành',
    'DISQUALIFIED' => 'Bị loại',
    'ABSENT' => 'Vắng mặt',
    'CHECKED_IN' => 'Đã check-in',
    'REGISTERED' => 'Đã đăng ký',
    _ => status ?? '—',
  };
}

String raceStatusLabel(String? status) {
  return switch (status) {
    'RESULT_CONFIRMED' => 'Đã chốt kết quả',
    'ONGOING' => 'Đang diễn ra',
    'SCHEDULED' => 'Đã lên lịch',
    'CANCELLED' => 'Đã hủy',
    _ => status ?? '—',
  };
}
