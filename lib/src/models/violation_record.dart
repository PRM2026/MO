enum ViolationReviewStatus { confirmed, pending }

class ViolationRecordItem {
  const ViolationRecordItem({
    required this.horseLabel,
    required this.violationType,
    required this.note,
    required this.timeLabel,
    required this.status,
    this.severityHigh = false,
  });

  final String horseLabel;
  final String violationType;
  final String note;
  final String timeLabel;
  final ViolationReviewStatus status;
  final bool severityHigh;

  String get statusLabel {
    switch (status) {
      case ViolationReviewStatus.confirmed:
        return 'Đã xác nhận';
      case ViolationReviewStatus.pending:
        return 'Đang xem xét';
    }
  }
}

class ViolationFormOptions {
  const ViolationFormOptions({
    required this.horses,
    required this.violationTypes,
  });

  final List<String> horses;
  final List<String> violationTypes;

  static ViolationFormOptions sample() => const ViolationFormOptions(
        horses: [
          'H042 - Crimson Blaze',
          'H089 - Silver Wind',
          'H112 - Midnight Shadow',
        ],
        violationTypes: [
          'Lấn làn (Track Interference)',
          'Xuất phát sớm (False Start)',
          'Sử dụng roi quá mức',
          'Cản trở đối thủ trái phép',
        ],
      );
}

class ViolationsPageData {
  const ViolationsPageData({
    required this.options,
    required this.records,
    required this.totalViolations,
    required this.pendingCount,
    this.profileImageUrl,
  });

  final ViolationFormOptions options;
  final List<ViolationRecordItem> records;
  final int totalViolations;
  final int pendingCount;
  final String? profileImageUrl;

  static ViolationsPageData sample() {
    return ViolationsPageData(
      profileImageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBBx94VMpBIgDLPM0ihsFtUzIMVzqFWul2y8Z3P-UOcHZGJ4UH1jpyyW0m36cdhemVrvGvKaQ0TK7AmBn0bueNgyJ2YQyXkSSLG7zhIG0ng1CoPnAg6j7gqYZqG2MC9PHZ0e4s4VafhUgpYqEc8kaIOnL1JAFw5R36o9K0JUKkQ7-REpqYjDXzN93moOEelYoFfhjtyjrcMRWhUjF_81-F-FQ6J05gmFD-9RB4B0GK7UuBZj5zAoW-Ro97HjnQ9F1LY0H_X70gz3DM',
      options: ViolationFormOptions.sample(),
      totalViolations: 3,
      pendingCount: 1,
      records: const [
        ViolationRecordItem(
          horseLabel: 'H112 - Midnight Shadow',
          violationType: 'Lấn làn nghiêm trọng',
          note: 'Cố tình ép làn 02 tại khúc cua thứ 3, gây nguy hiểm...',
          timeLabel: '14:25:02',
          status: ViolationReviewStatus.confirmed,
          severityHigh: true,
        ),
        ViolationRecordItem(
          horseLabel: 'H042 - Crimson Blaze',
          violationType: 'Xuất phát sớm',
          note: 'Rời lồng trước hiệu lệnh 0.15s.',
          timeLabel: '14:10:15',
          status: ViolationReviewStatus.pending,
        ),
      ],
    );
  }
}
