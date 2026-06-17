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

class OwnerHorseRaceHistoryItem {
  const OwnerHorseRaceHistoryItem({
    required this.id,
    required this.raceName,
    required this.tournamentName,
    this.racedAt,
    this.status,
    this.rank,
    this.result,
  });

  final String id;
  final String raceName;
  final String tournamentName;
  final DateTime? racedAt;
  final String? status;
  final int? rank;
  final String? result;

  factory OwnerHorseRaceHistoryItem.fromJson(Map<String, dynamic> json) {
    final raceName = _readFirstString(json, const [
      'raceName',
      'name',
      'title',
    ]);
    final tournamentName = _readFirstString(json, const [
      'tournamentName',
      'tournament',
    ]);

    return OwnerHorseRaceHistoryItem(
      id: '${json['id'] ?? json['raceId'] ?? ''}',
      raceName: raceName.isEmpty ? 'Cuộc đua' : raceName,
      tournamentName: tournamentName,
      racedAt: _parseDate(
        json['racedAt'] ??
            json['raceDate'] ??
            json['scheduledStartAt'] ??
            json['completedAt'],
      ),
      status: _readNullableString(json['status']),
      rank:
          (json['rank'] as num?)?.toInt() ??
          (json['position'] as num?)?.toInt(),
      result: _readNullableString(json['result']),
    );
  }
}

class OwnerHorseItem {
  const OwnerHorseItem({
    required this.id,
    required this.name,
    required this.breed,
    required this.imageUrl,
    required this.documentUrl,
    required this.statusCode,
    required this.statusLabel,
    this.age,
    this.gender,
    this.color,
    this.heightCm,
    this.weightKg,
    this.reviewReason,
    this.performance = const OwnerHorsePerformance(),
    this.raceHistory = const [],
    this.rankLabel,
  });

  final String id;
  final String name;
  final String breed;
  final String imageUrl;
  final String documentUrl;
  final String statusCode;
  final String statusLabel;
  final int? age;
  final String? gender;
  final String? color;
  final double? heightCm;
  final double? weightKg;
  final String? reviewReason;
  final OwnerHorsePerformance performance;
  final List<OwnerHorseRaceHistoryItem> raceHistory;
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
    final raceHistoryJson = json['raceHistory'];

    return OwnerHorseItem(
      id: '${json['id'] ?? ''}',
      name: (json['name'] as String?)?.trim().isNotEmpty == true
          ? json['name']!.trim()
          : 'Ngựa chưa đặt tên',
      breed: (json['breed'] as String?)?.trim().isNotEmpty == true
          ? json['breed']!.trim()
          : '—',
      imageUrl: ImageUrlResolver.resolve(json['imageUrl'] as String?),
      documentUrl: ImageUrlResolver.resolve(json['documentUrl'] as String?),
      statusCode: status,
      statusLabel: _statusLabel(status),
      age: (json['age'] as num?)?.toInt(),
      gender: json['gender'] as String?,
      color: json['color'] as String?,
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      reviewReason: json['reviewReason'] as String?,
      performance: performance,
      raceHistory: raceHistoryJson is List
          ? raceHistoryJson
                .whereType<Map<String, dynamic>>()
                .map(OwnerHorseRaceHistoryItem.fromJson)
                .toList(growable: false)
          : const [],
    );
  }

  OwnerHorseItem copyWith({String? rankLabel}) {
    return OwnerHorseItem(
      id: id,
      name: name,
      breed: breed,
      imageUrl: imageUrl,
      documentUrl: documentUrl,
      statusCode: statusCode,
      statusLabel: statusLabel,
      age: age,
      gender: gender,
      color: color,
      heightCm: heightCm,
      weightKg: weightKg,
      reviewReason: reviewReason,
      performance: performance,
      raceHistory: raceHistory,
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

class OwnerHorseDetail {
  const OwnerHorseDetail({
    required this.id,
    required this.name,
    required this.breed,
    required this.imageUrl,
    required this.documentUrl,
    required this.statusCode,
    required this.statusLabel,
    required this.raceHistory,
    this.ownerId,
    this.ownerUsername,
    this.age,
    this.gender,
    this.color,
    this.heightCm,
    this.weightKg,
    this.reviewReason,
    this.performance = const OwnerHorsePerformance(),
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final int? ownerId;
  final String? ownerUsername;
  final String name;
  final String breed;
  final int? age;
  final String? gender;
  final String? color;
  final double? heightCm;
  final double? weightKg;
  final String imageUrl;
  final String documentUrl;
  final String statusCode;
  final String statusLabel;
  final String? reviewReason;
  final OwnerHorsePerformance performance;
  final List<OwnerHorseRaceHistoryItem> raceHistory;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory OwnerHorseDetail.fromJson(Map<String, dynamic> json) {
    final status =
        (json['status'] as String?)?.trim().toUpperCase() ?? 'PENDING';
    final performanceJson = json['performance'];
    final raceHistoryJson = json['raceHistory'];
    final name = _readFirstString(json, const ['name', 'horseName']);
    final breed = _readFirstString(json, const ['breed']);

    return OwnerHorseDetail(
      id: '${json['id'] ?? ''}',
      ownerId: (json['ownerId'] as num?)?.toInt(),
      ownerUsername: _readNullableString(json['ownerUsername']),
      name: name.isNotEmpty ? name : 'Ngựa chưa đặt tên',
      breed: breed.isNotEmpty ? breed : '—',
      age: (json['age'] as num?)?.toInt(),
      gender: _readNullableString(json['gender']),
      color: _readNullableString(json['color']),
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      imageUrl: ImageUrlResolver.resolve(json['imageUrl'] as String?),
      documentUrl: ImageUrlResolver.resolve(json['documentUrl'] as String?),
      statusCode: status,
      statusLabel: _statusLabel(status),
      reviewReason: _readNullableString(json['reviewReason']),
      performance: performanceJson is Map<String, dynamic>
          ? OwnerHorsePerformance.fromJson(performanceJson)
          : const OwnerHorsePerformance(),
      raceHistory: raceHistoryJson is List
          ? raceHistoryJson
                .whereType<Map<String, dynamic>>()
                .map(OwnerHorseRaceHistoryItem.fromJson)
                .toList(growable: false)
          : const [],
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }
}

class OwnerHorseFormData {
  const OwnerHorseFormData({
    this.name,
    this.breed,
    this.age,
    this.gender,
    this.color,
    this.heightCm,
    this.weightKg,
    this.imagePath,
    this.documentPath,
  });

  final String? name;
  final String? breed;
  final int? age;
  final String? gender;
  final String? color;
  final double? heightCm;
  final double? weightKg;
  final String? imagePath;
  final String? documentPath;

  Map<String, String> toFields({required bool includeEmptyName}) {
    final fields = <String, String>{};
    _putString(fields, 'name', name, includeEmpty: includeEmptyName);
    _putString(fields, 'breed', breed);
    _putNumber(fields, 'age', age);
    _putString(fields, 'gender', gender);
    _putString(fields, 'color', color);
    _putNumber(fields, 'heightCm', heightCm);
    _putNumber(fields, 'weightKg', weightKg);
    return fields;
  }

  Map<String, String> toFilePaths() {
    final files = <String, String>{};
    _putString(files, 'image', imagePath);
    _putString(files, 'document', documentPath);
    return files;
  }
}

String _formatDecimal(double value) {
  return value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(1);
}

DateTime? _parseDate(Object? value) {
  if (value is! String || value.trim().isEmpty) return null;
  return DateTime.tryParse(value)?.toLocal();
}

String _readFirstString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = _readNullableString(json[key]);
    if (value != null && value.isNotEmpty) return value;
  }
  return '';
}

String? _readNullableString(Object? value) {
  if (value == null) return null;
  if (value is String) return value.trim();
  return value.toString();
}

void _putString(
  Map<String, String> fields,
  String key,
  String? value, {
  bool includeEmpty = false,
}) {
  final trimmed = value?.trim();
  if (trimmed == null) return;
  if (trimmed.isEmpty && !includeEmpty) return;
  fields[key] = trimmed;
}

void _putNumber(Map<String, String> fields, String key, num? value) {
  if (value == null) return;
  fields[key] = value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toString();
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
