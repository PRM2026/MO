import 'owner_dashboard_data.dart';
import '../utils/image_url_resolver.dart';

class OwnerHorsePerformance {
  const OwnerHorsePerformance({
    this.totalRaces = 0,
    this.wins = 0,
    this.winRate = 0,
  });

  final int totalRaces;
  final int wins;
  final double winRate;

  factory OwnerHorsePerformance.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const OwnerHorsePerformance();

    return OwnerHorsePerformance(
      totalRaces: (json['totalRaces'] as num?)?.toInt() ?? 0,
      wins: (json['wins'] as num?)?.toInt() ?? 0,
      winRate: (json['winRate'] as num?)?.toDouble() ?? 0,
    );
  }

  String get winRateLabel {
    if (totalRaces == 0) return '—';
    return '${winRate.round()}%';
  }
}

class OwnerHorseItem {
  const OwnerHorseItem({
    required this.id,
    required this.name,
    required this.breed,
    required this.imageUrl,
    required this.statusCode,
    required this.statusLabel,
    this.age,
    this.gender,
    this.color,
    this.heightCm,
    this.weightKg,
    this.reviewReason,
    this.performance = const OwnerHorsePerformance(),
    this.rankLabel,
  });

  final String id;
  final String name;
  final String breed;
  final String imageUrl;
  final String statusCode;
  final String statusLabel;
  final int? age;
  final String? gender;
  final String? color;
  final double? heightCm;
  final double? weightKg;
  final String? reviewReason;
  final OwnerHorsePerformance performance;
  final String? rankLabel;

  String get ageLabel => age == null ? 'Chưa cập nhật' : '$age tuổi';

  String get genderLabel {
    final value = gender?.trim();
    return value == null || value.isEmpty ? 'Chưa cập nhật' : value;
  }

  String get colorLabel {
    final value = color?.trim();
    return value == null || value.isEmpty ? 'Chưa cập nhật' : value;
  }

  String get bodyMetricsLabel {
    final values = <String>[];
    if (heightCm != null) values.add('${_formatDecimal(heightCm!)} cm');
    if (weightKg != null) values.add('${_formatDecimal(weightKg!)} kg');
    return values.isEmpty ? 'Chưa cập nhật' : values.join(' • ');
  }

  bool get isLegend => performance.wins >= 10 || performance.winRate >= 80;

  bool get isProspect => statusCode == 'PENDING' || performance.totalRaces < 3;

  bool get isRacing => statusCode == 'APPROVED';

  factory OwnerHorseItem.fromJson(Map<String, dynamic> json) {
    final status =
        (json['status'] as String?)?.trim().toUpperCase() ?? 'PENDING';
    final performanceJson = json['performance'];
    OwnerHorsePerformance performance = const OwnerHorsePerformance();
    if (performanceJson is Map<String, dynamic>) {
      performance = OwnerHorsePerformance.fromJson(performanceJson);
    }

    return OwnerHorseItem(
      id: '${json['id'] ?? ''}',
      name: (json['name'] as String?)?.trim().isNotEmpty == true
          ? json['name']!.trim()
          : 'Ngựa chưa đặt tên',
      breed: (json['breed'] as String?)?.trim().isNotEmpty == true
          ? json['breed']!.trim()
          : '—',
      imageUrl: ImageUrlResolver.resolve(json['imageUrl'] as String?),
      statusCode: status,
      statusLabel: _statusLabel(status),
      age: (json['age'] as num?)?.toInt(),
      gender: json['gender'] as String?,
      color: json['color'] as String?,
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      reviewReason: json['reviewReason'] as String?,
      performance: performance,
    );
  }

  OwnerHorseItem copyWith({String? rankLabel}) {
    return OwnerHorseItem(
      id: id,
      name: name,
      breed: breed,
      imageUrl: imageUrl,
      statusCode: statusCode,
      statusLabel: statusLabel,
      age: age,
      gender: gender,
      color: color,
      heightCm: heightCm,
      weightKg: weightKg,
      reviewReason: reviewReason,
      performance: performance,
      rankLabel: rankLabel ?? this.rankLabel,
    );
  }

  OwnerFeaturedHorse toFeatured({String? rankLabel}) {
    return OwnerFeaturedHorse(
      id: id,
      name: name,
      subtitle: breed,
      imageUrl: imageUrl,
      rankLabel: rankLabel ?? this.rankLabel,
    );
  }
}

String _formatDecimal(double value) {
  return value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(1);
}

String _statusLabel(String status) {
  return switch (status) {
    'APPROVED' => 'Đã duyệt',
    'PENDING' => 'Chờ duyệt',
    'REJECTED' => 'Từ chối',
    'SUSPENDED' => 'Tạm khóa',
    _ => status,
  };
}

enum OwnerHorseFilter { all, racing, legend, prospect }

extension OwnerHorseFilterX on OwnerHorseFilter {
  String get label {
    return switch (this) {
      OwnerHorseFilter.all => 'Tất cả',
      OwnerHorseFilter.racing => 'Đang thi đấu',
      OwnerHorseFilter.legend => 'Huyền thoại',
      OwnerHorseFilter.prospect => 'Triển vọng',
    };
  }
}
