import '../utils/image_url_resolver.dart';

const ownerJockeyInvitationStatusLabels = {
  'PENDING': 'Chờ phản hồi',
  'ACCEPTED': 'Đã nhận',
  'REJECTED': 'Từ chối',
  'CANCELLED': 'Đã hủy',
};

class OwnerJockeyInvitation {
  const OwnerJockeyInvitation({
    required this.id,
    required this.statusCode,
    required this.statusLabel,
    this.ownerId,
    this.ownerUsername,
    this.jockeyId,
    this.jockeyUsername,
    this.jockeyProfileId,
    this.horseId,
    this.horseName,
    this.raceId,
    this.raceName,
    this.tournamentId,
    this.tournamentName,
    this.message,
    this.responseNote,
    this.remunerationAmount,
    this.respondedAt,
    this.cancelledAt,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final Object? ownerId;
  final String? ownerUsername;
  final Object? jockeyId;
  final String? jockeyUsername;
  final Object? jockeyProfileId;
  final Object? horseId;
  final String? horseName;
  final Object? raceId;
  final String? raceName;
  final Object? tournamentId;
  final String? tournamentName;
  final String statusCode;
  final String statusLabel;
  final String? message;
  final String? responseNote;
  final num? remunerationAmount;
  final DateTime? respondedAt;
  final DateTime? cancelledAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isPending => statusCode == 'PENDING';

  factory OwnerJockeyInvitation.fromJson(Map<String, dynamic> json) {
    final status = _statusCode(json['status']);
    return OwnerJockeyInvitation(
      id: '${json['id'] ?? ''}',
      ownerId: _readId(json['ownerId']),
      ownerUsername: _readNullableString(json['ownerUsername']),
      jockeyId: _readId(json['jockeyId']),
      jockeyUsername: _readNullableString(json['jockeyUsername']),
      jockeyProfileId: _readId(json['jockeyProfileId']),
      horseId: _readId(json['horseId']),
      horseName: _readNullableString(json['horseName']),
      raceId: _readId(json['raceId']),
      raceName: _readNullableString(json['raceName']),
      tournamentId: _readId(json['tournamentId']),
      tournamentName: _readNullableString(json['tournamentName']),
      statusCode: status,
      statusLabel: _statusLabel(status),
      message: _readNullableString(json['message']),
      responseNote: _readNullableString(json['responseNote']),
      remunerationAmount: _readNum(json['remunerationAmount']),
      respondedAt: _parseDate(json['respondedAt']),
      cancelledAt: _parseDate(json['cancelledAt']),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }
}

class OwnerJockeyInvitationFormData {
  const OwnerJockeyInvitationFormData({
    this.horseId,
    this.raceId,
    this.jockeyId,
    this.remunerationAmount,
    this.message,
  });

  final Object? horseId;
  final Object? raceId;
  final Object? jockeyId;
  final num? remunerationAmount;
  final String? message;

  String? validate() {
    if (horseId == null || horseId.toString().trim().isEmpty) {
      return 'Vui lòng chọn ngựa.';
    }
    if (raceId == null || raceId.toString().trim().isEmpty) {
      return 'Vui lòng chọn cuộc đua.';
    }
    if (jockeyId == null || jockeyId.toString().trim().isEmpty) {
      return 'Vui lòng chọn jockey.';
    }
    final amount = remunerationAmount;
    if (amount == null) {
      return 'Vui lòng nhập thù lao.';
    }
    if (amount < 0) {
      return 'Thù lao không được nhỏ hơn 0.';
    }
    final trimmedMessage = message?.trim();
    if (trimmedMessage != null && trimmedMessage.length > 1000) {
      return 'Lời nhắn tối đa 1000 ký tự.';
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    final body = <String, dynamic>{
      'horseId': horseId,
      'raceId': raceId,
      'jockeyId': jockeyId,
      'remunerationAmount': remunerationAmount,
    };

    final trimmedMessage = message?.trim();
    if (trimmedMessage != null && trimmedMessage.isNotEmpty) {
      body['message'] = trimmedMessage;
    }

    return body;
  }
}

class OwnerAcceptedJockey {
  const OwnerAcceptedJockey({
    required this.id,
    this.invitationId,
    this.jockeyId,
    this.jockeyUsername,
    this.jockeyFullName,
    this.jockeyAvatarUrl,
    this.horseId,
    this.horseName,
    this.raceId,
    this.raceName,
    this.tournamentId,
    this.tournamentName,
    this.acceptedAt,
  });

  final String id;
  final Object? invitationId;
  final Object? jockeyId;
  final String? jockeyUsername;
  final String? jockeyFullName;
  final String? jockeyAvatarUrl;
  final Object? horseId;
  final String? horseName;
  final Object? raceId;
  final String? raceName;
  final Object? tournamentId;
  final String? tournamentName;
  final DateTime? acceptedAt;

  String get displayName {
    final name = jockeyFullName?.trim();
    if (name != null && name.isNotEmpty) return name;
    final username = jockeyUsername?.trim();
    if (username != null && username.isNotEmpty) return username;
    return jockeyId == null ? 'Jockey' : 'Jockey #$jockeyId';
  }

  factory OwnerAcceptedJockey.fromJson(Map<String, dynamic> json) {
    final jockey = _readMap(json['jockey']);
    final horse = _readMap(json['horse']);
    final race = _readMap(json['race']);
    final tournament = _readMap(json['tournament']);

    return OwnerAcceptedJockey(
      id: '${json['id'] ?? json['invitationId'] ?? ''}',
      invitationId: _readId(json['invitationId'] ?? json['id']),
      jockeyId: _readId(json['jockeyId'] ?? jockey?['id'] ?? jockey?['userId']),
      jockeyUsername: _readFirstString([
        json['jockeyUsername'],
        jockey?['username'],
      ]),
      jockeyFullName: _readFirstString([
        json['jockeyFullName'],
        json['jockeyName'],
        jockey?['fullName'],
        jockey?['name'],
      ]),
      jockeyAvatarUrl: ImageUrlResolver.resolve(
        _readFirstString([
          json['jockeyAvatarUrl'],
          json['avatarUrl'],
          jockey?['avatarUrl'],
          jockey?['profileImageUrl'],
        ]),
      ),
      horseId: _readId(json['horseId'] ?? horse?['id']),
      horseName: _readFirstString([json['horseName'], horse?['name']]),
      raceId: _readId(json['raceId'] ?? race?['id']),
      raceName: _readFirstString([json['raceName'], race?['name']]),
      tournamentId: _readId(json['tournamentId'] ?? tournament?['id']),
      tournamentName: _readFirstString([
        json['tournamentName'],
        tournament?['name'],
        tournament?['title'],
      ]),
      acceptedAt: _parseDate(
        json['acceptedAt'] ?? json['respondedAt'] ?? json['createdAt'],
      ),
    );
  }
}

class OwnerAvailableJockey {
  const OwnerAvailableJockey({
    required this.id,
    this.username,
    this.fullName,
    this.email,
    this.avatarUrl,
    this.profileId,
    this.rating,
    this.experienceYears,
  });

  final String id;
  final String? username;
  final String? fullName;
  final String? email;
  final String? avatarUrl;
  final String? profileId;
  final double? rating;
  final int? experienceYears;

  String get displayName {
    final name = fullName?.trim();
    if (name != null && name.isNotEmpty) return name;
    final handle = username?.trim();
    if (handle != null && handle.isNotEmpty) return handle;
    return id.isEmpty ? 'Jockey' : 'Jockey #$id';
  }

  factory OwnerAvailableJockey.fromJson(Map<String, dynamic> json) {
    final profile = _readMap(json['profile']);
    return OwnerAvailableJockey(
      id: _readId(json['id'] ?? json['userId'] ?? profile?['userId']) ?? '',
      username: _readNullableString(json['username']),
      fullName: _readFirstString([
        json['fullName'],
        json['name'],
        json['displayName'],
        profile?['fullName'],
        profile?['name'],
      ]),
      email: _readNullableString(json['email']),
      avatarUrl: ImageUrlResolver.resolve(
        _readFirstString([
          json['avatarUrl'],
          json['profileImageUrl'],
          profile?['avatarUrl'],
          profile?['imageUrl'],
        ]),
      ),
      profileId: _readId(json['profileId'] ?? profile?['id']),
      rating: _readNum(json['rating'] ?? profile?['rating'])?.toDouble(),
      experienceYears: _readInt(
        json['experienceYears'] ?? profile?['experienceYears'],
      ),
    );
  }
}

String _statusCode(Object? value) {
  final text = _readNullableString(value);
  return text == null || text.isEmpty ? 'PENDING' : text.toUpperCase();
}

String _statusLabel(String status) {
  return ownerJockeyInvitationStatusLabels[status] ?? status;
}

DateTime? _parseDate(Object? value) {
  if (value is! String || value.trim().isEmpty) return null;
  return DateTime.tryParse(value)?.toLocal();
}

Map<String, dynamic>? _readMap(Object? value) {
  return value is Map<String, dynamic> ? value : null;
}

String? _readNullableString(Object? value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

String? _readFirstString(List<Object?> values) {
  for (final value in values) {
    final text = _readNullableString(value);
    if (text != null) return text;
  }
  return null;
}

int? _readInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim());
  return null;
}

String? _readId(Object? value) {
  final id = value?.toString().trim();
  return id == null || id.isEmpty ? null : id;
}

num? _readNum(Object? value) {
  if (value is num) return value;
  if (value is String) return num.tryParse(value.trim());
  return null;
}
