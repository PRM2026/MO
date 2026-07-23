class AuthSession {
  const AuthSession({
    required this.token,
    required this.tokenType,
    this.userId,
    this.username,
    this.email,
    this.fullName,
    this.role,
    this.pendingRole,
    this.roleApprovalStatus,
    this.twoFactorRequired = false,
    this.challengeId,
    this.challengeExpiresAt,
  });

  final String token;
  final String tokenType;
  final int? userId;
  final String? username;
  final String? email;
  final String? fullName;
  final String? role;
  final String? pendingRole;
  final String? roleApprovalStatus;
  final bool twoFactorRequired;
  final String? challengeId;
  final DateTime? challengeExpiresAt;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      token: (json['token'] as String?) ?? '',
      tokenType: (json['tokenType'] as String?) ?? 'Bearer',
      userId: _readInt(json['userId']),
      username: json['username'] as String?,
      email: json['email'] as String?,
      fullName: json['fullName'] as String?,
      role: _readString(json['role']),
      pendingRole: _readString(json['pendingRole']),
      roleApprovalStatus: _readString(json['roleApprovalStatus']),
      twoFactorRequired: json['twoFactorRequired'] as bool? ?? false,
      challengeId: _readString(json['challengeId']),
      challengeExpiresAt: DateTime.tryParse(
        _readString(json['challengeExpiresAt']) ?? '',
      ),
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
}
