import '../models/referee_race_participant_response.dart';
import '../models/referee_race_response.dart';
import '../models/referee_race_result_response.dart';
import '../utils/currency_format.dart';
import '../utils/race_time_format.dart' as race_format;

class RefereeRaceOption {
  const RefereeRaceOption({
    required this.id,
    required this.label,
    required this.status,
  });

  final String id;
  final String label;
  final String status;
}

class RaceFinisherRow {
  const RaceFinisherRow({
    required this.rank,
    required this.horseName,
    required this.jockeyName,
    required this.finishTime,
    required this.gapLabel,
    this.gapIsPositive = false,
    this.highlightRank = false,
    this.statusLabel,
  });

  final int? rank;
  final String horseName;
  final String jockeyName;
  final String finishTime;
  final String gapLabel;
  final bool gapIsPositive;
  final bool highlightRank;
  final String? statusLabel;
}

class PrizeBreakdownRow {
  const PrizeBreakdownRow({
    required this.label,
    required this.amount,
    this.highlight = false,
  });

  final String label;
  final String amount;
  final bool highlight;
}

class RaceResultConfirmationData {
  const RaceResultConfirmationData({
    required this.races,
    required this.selectedRaceId,
    required this.raceName,
    required this.raceCode,
    required this.raceStatus,
    required this.raceStatusLabel,
    required this.isFinalized,
    required this.canConfirm,
    required this.finishers,
    required this.totalPrizePool,
    required this.prizeBreakdown,
    this.profileImageUrl,
    this.infoMessage,
    this.resultFinalizedAt,
  });

  final List<RefereeRaceOption> races;
  final String? selectedRaceId;
  final String raceName;
  final String raceCode;
  final String raceStatus;
  final String raceStatusLabel;
  final bool isFinalized;
  final bool canConfirm;
  final List<RaceFinisherRow> finishers;
  final String totalPrizePool;
  final List<PrizeBreakdownRow> prizeBreakdown;
  final String? profileImageUrl;
  final String? infoMessage;
  final DateTime? resultFinalizedAt;

  factory RaceResultConfirmationData.empty({String? profileImageUrl}) {
    return RaceResultConfirmationData(
      races: const [],
      selectedRaceId: null,
      raceName: '—',
      raceCode: '—',
      raceStatus: '',
      raceStatusLabel: '—',
      isFinalized: false,
      canConfirm: false,
      finishers: const [],
      totalPrizePool: '0',
      prizeBreakdown: const [],
      profileImageUrl: profileImageUrl,
      infoMessage: 'Chưa có cuộc đua nào để xem kết quả.',
    );
  }

  static RaceResultConfirmationData fromApi({
    required List<RefereeRaceResponse> allRaces,
    required RefereeRaceResponse selectedRace,
    required List<RefereeRaceResultResponse> results,
    required List<RefereeRaceParticipantResponse> participants,
    String? profileImageUrl,
  }) {
    final relevant = allRaces
        .where(
          (race) =>
              race.status == 'ONGOING' || race.status == 'RESULT_CONFIRMED',
        )
        .toList(growable: false);

    final raceOptions = relevant
        .map(
          (race) => RefereeRaceOption(
            id: race.id ?? '',
            label:
                '${race.name ?? 'Cuộc đua #${race.id}'} '
                '(${race_format.raceStatusLabel(race.status)})',
            status: race.status ?? '',
          ),
        )
        .toList(growable: false);

    final isFinalized = selectedRace.status == 'RESULT_CONFIRMED';
    final finishers = results.isNotEmpty
        ? _finishersFromResults(results)
        : _finishersFromParticipants(participants);

    final prizeData = _buildPrizeData(selectedRace, results);

    return RaceResultConfirmationData(
      profileImageUrl: profileImageUrl,
      races: raceOptions,
      selectedRaceId: selectedRace.id,
      raceName: selectedRace.name ?? 'Cuộc đua #${selectedRace.id}',
      raceCode: '#${selectedRace.id ?? '—'}',
      raceStatus: selectedRace.status ?? '',
      raceStatusLabel: race_format.raceStatusLabel(selectedRace.status),
      isFinalized: isFinalized,
      canConfirm: false,
      finishers: finishers,
      totalPrizePool: prizeData.$1,
      prizeBreakdown: prizeData.$2,
      resultFinalizedAt: selectedRace.resultFinalizedAt,
      infoMessage: _infoMessage(
        isFinalized: isFinalized,
        hasResults: results.isNotEmpty,
        hasParticipants: participants.isNotEmpty,
      ),
    );
  }

  static String? _infoMessage({
    required bool isFinalized,
    required bool hasResults,
    required bool hasParticipants,
  }) {
    if (isFinalized && hasResults) return null;
    if (isFinalized && !hasResults) {
      return 'Cuộc đua đã chốt kết quả nhưng chưa có dữ liệu chi tiết.';
    }
    if (!hasParticipants) {
      return 'Cuộc đua chưa có người tham gia.';
    }
    if (!hasResults) {
      return 'Cuộc đua đang diễn ra — kết quả chưa được chốt.';
    }
    return null;
  }

  static List<RaceFinisherRow> _finishersFromResults(
    List<RefereeRaceResultResponse> results,
  ) {
    final sorted = [...results]
      ..sort((a, b) {
        final rankA = a.rank ?? 999;
        final rankB = b.rank ?? 999;
        return rankA.compareTo(rankB);
      });

    final leaderMillis = sorted
        .where(
          (item) => item.status == 'FINISHED' && item.finishTimeMillis != null,
        )
        .map((item) => item.finishTimeMillis)
        .fold<int?>(null, (prev, curr) => prev ?? curr);

    return sorted
        .map(
          (item) => RaceFinisherRow(
            rank: item.rank,
            horseName: item.horseName ?? '—',
            jockeyName: item.jockeyUsername ?? '—',
            finishTime: item.status == 'FINISHED'
                ? race_format.formatRaceFinishTime(item.finishTimeMillis)
                : race_format.participantStatusLabel(item.status),
            gapLabel: item.status == 'FINISHED'
                ? race_format.formatRaceGap(item.finishTimeMillis, leaderMillis)
                : '—',
            gapIsPositive:
                item.finishTimeMillis != null &&
                leaderMillis != null &&
                item.finishTimeMillis! > leaderMillis,
            highlightRank: item.rank == 1 && item.status == 'FINISHED',
            statusLabel: race_format.participantStatusLabel(item.status),
          ),
        )
        .toList(growable: false);
  }

  static List<RaceFinisherRow> _finishersFromParticipants(
    List<RefereeRaceParticipantResponse> participants,
  ) {
    return participants
        .map(
          (item) => RaceFinisherRow(
            rank: null,
            horseName: item.horseName ?? '—',
            jockeyName: item.jockeyUsername ?? '—',
            finishTime: '—',
            gapLabel: '—',
            statusLabel: race_format.participantStatusLabel(item.status),
          ),
        )
        .toList(growable: false);
  }

  static (String, List<PrizeBreakdownRow>) _buildPrizeData(
    RefereeRaceResponse race,
    List<RefereeRaceResultResponse> results,
  ) {
    final prizes = [...race.prizes]
      ..sort((a, b) => (a.rank ?? 0).compareTo(b.rank ?? 0));

    if (prizes.isNotEmpty) {
      final total = prizes.fold<num>(
        0,
        (sum, prize) => sum + (prize.amount ?? 0),
      );
      return (
        formatVnd(total).replaceAll(' đ', ''),
        prizes
            .map(
              (prize) => PrizeBreakdownRow(
                label: 'Hạng ${prize.rank}:',
                amount: formatVnd(prize.amount),
                highlight: prize.rank == 1,
              ),
            )
            .toList(growable: false),
      );
    }

    if (results.isNotEmpty) {
      final total = results.fold<num>(
        0,
        (sum, item) => sum + (item.prizeAmount ?? 0),
      );
      return (
        formatVnd(total).replaceAll(' đ', ''),
        results
            .where((item) => item.rank != null && item.prizeAmount != null)
            .map(
              (item) => PrizeBreakdownRow(
                label: 'Hạng ${item.rank}:',
                amount: formatVnd(item.prizeAmount),
                highlight: item.rank == 1,
              ),
            )
            .toList(growable: false),
      );
    }

    return ('0', const []);
  }
}
