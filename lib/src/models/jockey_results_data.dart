import 'package:flutter/material.dart';

import '../constants/referee_colors.dart';
import '../utils/currency_format.dart';
import '../utils/wallet_labels.dart';
import 'jockey_performance_response.dart';
import 'jockey_race_response.dart';
import 'jockey_race_result_response.dart';
import 'wallet_transaction_response.dart';

enum JockeyResultRank { first, second, other, pending }

enum JockeyRaceResultState { available, pending, missing }

class JockeyResultsStatItem {
  const JockeyResultsStatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
    this.highlightValue = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;
  final bool highlightValue;
}

class JockeyRaceResultItem {
  const JockeyRaceResultItem({
    required this.raceId,
    this.tournamentId,
    required this.eventName,
    required this.scheduleLabel,
    required this.trackInfo,
    required this.statusCode,
    required this.statusLabel,
    required this.resultState,
    required this.rank,
    required this.rankLabel,
    required this.horseName,
    required this.finishTime,
    required this.challengePoints,
    required this.prizeAmount,
    required this.payoutStatus,
    this.scheduledStartAt,
  });

  final String raceId;
  final String? tournamentId;
  final String eventName;
  final String scheduleLabel;
  final String trackInfo;
  final String statusCode;
  final String statusLabel;
  final JockeyRaceResultState resultState;
  final JockeyResultRank rank;
  final String rankLabel;
  final String horseName;
  final String finishTime;
  final String challengePoints;
  final String prizeAmount;
  final String payoutStatus;
  final DateTime? scheduledStartAt;

  bool get hasResult => resultState == JockeyRaceResultState.available;

  Color get rankColor {
    return switch (rank) {
      JockeyResultRank.first => RefereeColors.championshipGold,
      JockeyResultRank.second => RefereeColors.secondary,
      JockeyResultRank.other => RefereeColors.successEmerald,
      JockeyResultRank.pending => RefereeColors.onSurfaceVariant,
    };
  }
}

class JockeyPrizePayoutItem {
  const JockeyPrizePayoutItem({
    required this.id,
    required this.typeLabel,
    required this.directionLabel,
    required this.amountLabel,
    required this.statusLabel,
    required this.statusCode,
    required this.referenceLabel,
    required this.createdAtLabel,
    this.note,
  });

  final String id;
  final String typeLabel;
  final String directionLabel;
  final String amountLabel;
  final String statusLabel;
  final String statusCode;
  final String referenceLabel;
  final String createdAtLabel;
  final String? note;

  bool get isSuccessful => statusCode == 'SUCCESS';
}

class JockeyResultsData {
  const JockeyResultsData({
    required this.stats,
    required this.results,
    required this.prizes,
  });

  final List<JockeyResultsStatItem> stats;
  final List<JockeyRaceResultItem> results;
  final List<JockeyPrizePayoutItem> prizes;

  factory JockeyResultsData.fromApi({
    required JockeyPerformanceResponse performance,
    required List<JockeyRaceResponse> races,
    required Map<String, JockeyRaceResultResponse?> jockeyResultsByRaceId,
    required List<WalletTransactionResponse> prizes,
  }) {
    final sortedRaces = [...races]
      ..sort(
        (a, b) => _compareDatesDesc(a.scheduledStartAt, b.scheduledStartAt),
      );
    final sortedPrizes = [...prizes]
      ..sort((a, b) => _compareDatesDesc(a.createdAt, b.createdAt));

    return JockeyResultsData(
      stats: [
        JockeyResultsStatItem(
          label: 'Tổng cuộc đua',
          value: performance.raceCount.toString(),
          icon: Icons.stadium_outlined,
          accentColor: RefereeColors.secondary,
        ),
        JockeyResultsStatItem(
          label: 'Đã hoàn thành',
          value: performance.completedRaceCount.toString(),
          icon: Icons.task_alt_outlined,
          accentColor: RefereeColors.successEmerald,
        ),
        JockeyResultsStatItem(
          label: 'Hạng 1 / 2 / 3',
          value:
              '${performance.firstPlaces} / ${performance.secondPlaces} / ${performance.thirdPlaces}',
          icon: Icons.military_tech_outlined,
          accentColor: RefereeColors.tertiary,
        ),
        JockeyResultsStatItem(
          label: 'Thù lao jockey',
          value: formatVnd(performance.totalJockeyPayout),
          icon: Icons.payments_outlined,
          accentColor: RefereeColors.championshipGold,
          highlightValue: true,
        ),
        JockeyResultsStatItem(
          label: 'Tiền thưởng',
          value: formatVnd(performance.totalPrizePayout),
          icon: Icons.emoji_events_outlined,
          accentColor: RefereeColors.championshipGold,
          highlightValue: true,
        ),
      ],
      results: sortedRaces
          .map(
            (race) => _mapRace(
              race,
              jockeyResultsByRaceId[race.id],
              jockeyResultsByRaceId.containsKey(race.id),
            ),
          )
          .toList(growable: false),
      prizes: sortedPrizes.map(_mapPrize).toList(growable: false),
    );
  }
}

JockeyRaceResultItem _mapRace(
  JockeyRaceResponse race,
  JockeyRaceResultResponse? result,
  bool resultWasRequested,
) {
  final statusCode = race.status?.trim().toUpperCase() ?? '';
  final state = result != null
      ? JockeyRaceResultState.available
      : resultWasRequested
      ? JockeyRaceResultState.missing
      : JockeyRaceResultState.pending;

  return JockeyRaceResultItem(
    raceId: race.id,
    tournamentId: race.tournamentId,
    eventName: _firstNonEmpty([race.name, 'Cuộc đua #${race.id}']),
    scheduleLabel: _dateTimeLabel(race.scheduledStartAt),
    trackInfo: _trackInfo(race),
    statusCode: statusCode,
    statusLabel: _raceStatusLabel(statusCode),
    resultState: state,
    rank: _rank(result, state),
    rankLabel: switch (state) {
      JockeyRaceResultState.available => result!.rankLabel,
      JockeyRaceResultState.missing => 'Chưa có kết quả',
      JockeyRaceResultState.pending => 'Chờ kết quả',
    },
    horseName: result?.horseLabel ?? 'Chưa cập nhật ngựa',
    finishTime: result?.finishTimeLabel ?? '—',
    challengePoints: result?.challengePointsLabel ?? '—',
    prizeAmount: result?.jockeyPrizeLabel ?? '—',
    payoutStatus: result?.payoutStatusLabel ?? '—',
    scheduledStartAt: race.scheduledStartAt,
  );
}

JockeyPrizePayoutItem _mapPrize(WalletTransactionResponse transaction) {
  final referenceParts = [
    transaction.referenceType,
    transaction.referenceId,
  ].where((value) => value != null && value.trim().isNotEmpty).cast<String>();
  final direction = transaction.direction?.trim().toUpperCase();
  final status = transaction.status?.trim().toUpperCase() ?? '';
  final isCredit =
      direction == null ||
      direction.isEmpty ||
      isWalletCreditDirection(direction);

  return JockeyPrizePayoutItem(
    id: transaction.id,
    typeLabel: walletTransactionTypeLabel(transaction.type),
    directionLabel: walletTransactionDirectionLabel(transaction.direction),
    amountLabel: '${isCredit ? '+' : '-'}${formatVnd(transaction.amount)}',
    statusLabel: walletTransactionStatusLabel(transaction.status),
    statusCode: status,
    referenceLabel: referenceParts.isEmpty
        ? 'Không có tham chiếu'
        : referenceParts.join(' #'),
    createdAtLabel: _dateTimeLabel(transaction.createdAt),
    note: transaction.note,
  );
}

JockeyResultRank _rank(
  JockeyRaceResultResponse? result,
  JockeyRaceResultState state,
) {
  if (state != JockeyRaceResultState.available || result == null) {
    return JockeyResultRank.pending;
  }
  return switch (result.rank) {
    1 => JockeyResultRank.first,
    2 => JockeyResultRank.second,
    _ => JockeyResultRank.other,
  };
}

String _raceStatusLabel(String status) {
  return switch (status) {
    'RESULT_CONFIRMED' => 'Đã có kết quả',
    'ONGOING' => 'Đang diễn ra',
    'SCHEDULED' => 'Đã lên lịch',
    'OPEN_REGISTRATION' => 'Đang mở đăng ký',
    'REGISTRATION_CLOSED' => 'Đã đóng đăng ký',
    'PUBLISHED' => 'Đã công bố',
    'CANCELLED' => 'Đã hủy',
    'DRAFT' => 'Bản nháp',
    _ => status.isEmpty ? 'Chưa rõ trạng thái' : status,
  };
}

String _trackInfo(JockeyRaceResponse race) {
  final venue = [race.venueName, race.provinceName]
      .where((value) => value?.trim().isNotEmpty == true)
      .cast<String>()
      .join(' • ');
  final values = [
    if (race.distance?.trim().isNotEmpty == true) race.distance!.trim(),
    if (venue.isNotEmpty) venue,
  ];
  return values.isEmpty
      ? 'Chưa cập nhật thông tin đường đua'
      : values.join(' • ');
}

String _dateTimeLabel(DateTime? value) {
  if (value == null) return 'Chưa cập nhật thời gian';
  final local = value.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$day/$month/${local.year} $hour:$minute';
}

String _firstNonEmpty(List<String?> values) {
  for (final value in values) {
    final trimmed = value?.trim();
    if (trimmed != null && trimmed.isNotEmpty) return trimmed;
  }
  return '';
}

int _compareDatesDesc(DateTime? a, DateTime? b) {
  if (a == null && b == null) return 0;
  if (a == null) return 1;
  if (b == null) return -1;
  return b.compareTo(a);
}
