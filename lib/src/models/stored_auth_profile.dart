import '../utils/role_utils.dart';

class StoredAuthProfile {
  const StoredAuthProfile({
    this.token,
    this.tokenType,
    this.email,
    this.fullName,
    this.role,
    this.pendingRole,
    this.roleApprovalStatus,
  });

  final String? token;
  final String? tokenType;
  final String? email;
  final String? fullName;
  final String? role;
  final String? pendingRole;
  final String? roleApprovalStatus;

  String get bearerToken {
    if (token == null || token!.isEmpty) return '—';
    final type = tokenType?.trim();
    if (type == null || type.isEmpty) return token!;
    return '$type $token';
  }

  String get normalizedRole => (role ?? 'USER').trim().toUpperCase();

  String get normalizedPendingRole =>
      (pendingRole ?? '').trim().toUpperCase();

  String get normalizedApprovalStatus =>
      (roleApprovalStatus ?? 'NONE').trim().toUpperCase();

  bool get isRolePending => normalizedApprovalStatus == 'PENDING';

  String get effectiveAppRole => resolveEffectiveAppRole(
        role: role,
        roleApprovalStatus: roleApprovalStatus,
      );
}
