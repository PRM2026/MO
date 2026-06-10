import 'package:flutter/material.dart';

class RaceFinisherRow {
  const RaceFinisherRow({
    required this.rank,
    required this.horseName,
    required this.jockeyName,
    required this.finishTime,
    required this.gapLabel,
    this.horseImageUrl,
    this.gapIsPositive = false,
    this.highlightRank = false,
  });

  final int rank;
  final String horseName;
  final String jockeyName;
  final String finishTime;
  final String gapLabel;
  final String? horseImageUrl;
  final bool gapIsPositive;
  final bool highlightRank;
}

class AppliedViolationSummary {
  const AppliedViolationSummary({
    required this.title,
    required this.penaltyDescription,
  });

  final String title;
  final String penaltyDescription;
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

class ActivityLogEntry {
  const ActivityLogEntry({
    required this.timeLabel,
    required this.message,
    this.isActive = false,
  });

  final String timeLabel;
  final String message;
  final bool isActive;
}

class RaceResultConfirmationData {
  const RaceResultConfirmationData({
    required this.raceCode,
    required this.finishers,
    required this.appliedViolations,
    required this.totalPrizePool,
    required this.prizeBreakdown,
    required this.activityLog,
    this.profileImageUrl,
  });

  final String raceCode;
  final List<RaceFinisherRow> finishers;
  final List<AppliedViolationSummary> appliedViolations;
  final String totalPrizePool;
  final List<PrizeBreakdownRow> prizeBreakdown;
  final List<ActivityLogEntry> activityLog;
  final String? profileImageUrl;

  static RaceResultConfirmationData sample() {
    return RaceResultConfirmationData(
      raceCode: '#829',
      profileImageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBsy6SGCQtMzTEGmY4mCNdZ-XxNbyQ9pN5UXqXB9-k9-uKywou8Jg5mqeNkgLB25WpxilX9If4jeTPeFR0UIYr2bgc7JTX0A472Zq5INlE63Auv0J5c-Fk9QVBiNm5VeuGIctw-P9nQy4qbpsBRuPgJaIVbCbHaKkv5RiDY5PF0xsUhmp8N-3wL-C1_dPd3LX5gasRSJRcHESjm2mBjsOOX9dWo0VSsu__jvRyo2EGicWO0RwK257S8wBQE2EcV9iQEAMDCT-1lQEQ',
      totalPrizePool: '150.000.000',
      finishers: const [
        RaceFinisherRow(
          rank: 1,
          horseName: 'Thần Mã 07',
          jockeyName: 'Nguyễn Văn A',
          finishTime: '02:14.42',
          gapLabel: '-',
          highlightRank: true,
          horseImageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuCDDd0OfEcLyheoJ6DonGCfFkfOIrX681EMEUjNTr1FTj413md2sv3YE7k8ZyT3gJDhEqS8Bz6kSxyeXxKdMMSxBD-w1RX9UNyozkqSlu9s9N-b-DexK6r9DkcYgky9GGelkZWfM5Kl2xZf_9qaPoJOASdueqi0s6f-CVR3afBYkOzvRfvJkymjW8JN56j9Cuq_KLpGGNFu07bpFTlAEvFIZH9NwfZ5CgtivTOFCEHHB3Ovd6gRgjw44c9bIsqhAMMTVxWaJYNShiY',
        ),
        RaceFinisherRow(
          rank: 2,
          horseName: 'Bạch Long',
          jockeyName: 'Lê Hoàng Nam',
          finishTime: '02:15.10',
          gapLabel: '+0.68s',
          gapIsPositive: true,
          horseImageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuCwl1MC8kdfurLWXGP_snLumlFo1cZWvtYCAGqlYXFsyPE29ex7sCe0ksNV_MzN_dxLC4Wd4393KHwhXf3Mtp3_jKIVkhy27SLMKEnFTNgqIqEt5PjtyDmOc4dmqcdvQi5ZyZq3-LUx_IWTnIR-xCY0RqHWngPWRib7pUGT8QjOwjOTsuQv5n0nsCo8oiloRhTBy7qutFVqWk7-XcCqotI0Gqmv0BFUGHMu9KqFuPMyFS-FnvQ_lcfEjuQulLQ9II9wlO000HSSnuc',
        ),
        RaceFinisherRow(
          rank: 3,
          horseName: 'Hắc Kỵ',
          jockeyName: 'Trần Minh',
          finishTime: '02:15.85',
          gapLabel: '+1.43s',
          gapIsPositive: true,
          horseImageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuCFYOrhwf7c3zcD0WXINBRHJSV89pisTDCEVUXgtt2eq-IvunRLf3wtOvT07FE1vbuPaLKtJWM3cEZV_JJo2K2koF3SDIs0hIVq4b80y1d2uDuRfpKhL5qsLeGMoJsbKhcKbH9n-JO4Nt9HIYAXccxjqw4jz8LXZg782GlhynjjtgbaZfrqrASJZVohLmS3_An1H5cLTgsB9EakaujVS3yKqb_WsCTpC2kJSNfT-IULK_5XKYM3ei0Jhw1d1N1PRMXcJshOL_lVpBo',
        ),
      ],
      appliedViolations: const [
        AppliedViolationSummary(
          title: 'Cản trở đường chạy (Ngựa #05)',
          penaltyDescription: 'Áp dụng: Cộng 2 giây vào kết quả cuối',
        ),
      ],
      prizeBreakdown: const [
        PrizeBreakdownRow(
          label: 'Hạng 1 (60%):',
          amount: '90.000.000 VND',
          highlight: true,
        ),
        PrizeBreakdownRow(
          label: 'Hạng 2 (25%):',
          amount: '37.500.000 VND',
        ),
        PrizeBreakdownRow(
          label: 'Hạng 3 (10%):',
          amount: '15.000.000 VND',
        ),
      ],
      activityLog: const [
        ActivityLogEntry(
          timeLabel: '14:45:02',
          message:
              'Dữ liệu hoàn thành từ Photo-Finish được tải lên.',
          isActive: true,
        ),
        ActivityLogEntry(
          timeLabel: '14:42:15',
          message: 'Điều hành viên áp dụng hình phạt cho Ngựa #05.',
        ),
        ActivityLogEntry(
          timeLabel: '14:38:50',
          message: 'Trọng tài biên xác nhận tín hiệu về đích an toàn.',
        ),
      ],
    );
  }
}
