import 'role_request_data.dart';

class RoleApplicationResponse {
  const RoleApplicationResponse({
    this.profileId,
    this.role,
    this.status,
    this.reviewReason,
    this.createdAt,
    this.reviewedAt,
    this.fullName,
  });

  final int? profileId;
  final String? role;
  final String? status;
  final String? reviewReason;
  final DateTime? createdAt;
  final DateTime? reviewedAt;
  final String? fullName;

  factory RoleApplicationResponse.fromJson(Map<String, dynamic> json) {
    return RoleApplicationResponse(
      profileId: (json['profileId'] as num?)?.toInt(),
      role: json['role'] as String?,
      status: json['status'] as String?,
      reviewReason: json['reviewReason'] as String?,
      createdAt: _parseDate(json['createdAt']),
      reviewedAt: _parseDate(json['reviewedAt']),
      fullName: json['fullName'] as String?,
    );
  }

  bool get hasRecord =>
      profileId != null &&
      role != null &&
      (status ?? 'NONE').toUpperCase() != 'NONE';

  SystemRoleType? get systemRole => _mapRole(role);

  RoleHistoryStatus? get historyStatus {
    return switch ((status ?? '').toUpperCase()) {
      'PENDING' => RoleHistoryStatus.pending,
      'APPROVED' => RoleHistoryStatus.approved,
      'REJECTED' => RoleHistoryStatus.rejected,
      _ => null,
    };
  }

  RoleApplicationHistoryItem? toHistoryItem() {
    final mappedRole = systemRole;
    final mappedStatus = historyStatus;
    if (mappedRole == null || mappedStatus == null) return null;

    final date = createdAt ?? reviewedAt;
    final formattedDate = date != null
        ? '${date.day.toString().padLeft(2, '0')}/'
              '${date.month.toString().padLeft(2, '0')}/'
              '${date.year}'
        : '—';

    final note = reviewReason?.trim().isNotEmpty == true
        ? reviewReason!.trim()
        : switch (mappedStatus) {
            RoleHistoryStatus.pending =>
              'Hồ sơ đang chờ ban quản trị xét duyệt.',
            RoleHistoryStatus.approved => 'Yêu cầu đã được phê duyệt.',
            RoleHistoryStatus.rejected => 'Yêu cầu đã bị từ chối.',
          };

    return RoleApplicationHistoryItem(
      role: mappedRole,
      submittedDate: formattedDate,
      status: mappedStatus,
      adminNote: note,
    );
  }

  static DateTime? _parseDate(Object? value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  static SystemRoleType? _mapRole(String? role) {
    return switch ((role ?? '').toUpperCase()) {
      'SPECTATOR' => SystemRoleType.spectator,
      'OWNER' => SystemRoleType.horseOwner,
      'JOCKEY' => SystemRoleType.jockey,
      'REFEREE' => SystemRoleType.referee,
      _ => null,
    };
  }
}

String translateUserRole(String? role) {
  return switch ((role ?? 'USER').toUpperCase()) {
    'USER' => 'Người dùng',
    'SPECTATOR' => 'Khán giả',
    'OWNER' => 'Chủ ngựa',
    'JOCKEY' => 'Nài ngựa',
    'REFEREE' => 'Trọng tài',
    'ADMIN' => 'Quản trị viên',
    _ => role ?? 'Người dùng',
  };
}
