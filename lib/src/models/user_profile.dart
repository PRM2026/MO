import '../utils/role_utils.dart';

class UserProfile {
  const UserProfile({
    this.id,
    this.username,
    this.email,
    this.fullName,
    this.role,
    this.pendingRole,
    this.roleApprovalStatus,
    this.roleReviewReason,
    this.avatarUrl,
  });

  final int? id;
  final String? username;
  final String? email;
  final String? fullName;
  final String? role;
  final String? pendingRole;
  final String? roleApprovalStatus;
  final String? roleReviewReason;
  final String? avatarUrl;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: _readInt(json['id']),
      username: json['username'] as String?,
      email: json['email'] as String?,
      fullName: json['fullName'] as String?,
      role: _readString(json['role']),
      pendingRole: _readString(json['pendingRole']),
      roleApprovalStatus: _readString(json['roleApprovalStatus']),
      roleReviewReason: json['roleReviewReason'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  static String? _readString(Object? value) {
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }

  static int? _readInt(Object? value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  String get normalizedRole => (role ?? 'USER').trim().toUpperCase();

  String get normalizedPendingRole => (pendingRole ?? '').trim().toUpperCase();

  String get normalizedApprovalStatus =>
      (roleApprovalStatus ?? 'NONE').trim().toUpperCase();

  /// Role used by the app shell until admin approves the application.
  String get effectiveAppRole => resolveEffectiveAppRole(
    role: role,
    roleApprovalStatus: roleApprovalStatus,
  );

  bool get isRolePending => normalizedApprovalStatus == 'PENDING';

  bool get isRoleRejected => normalizedApprovalStatus == 'REJECTED';
}
