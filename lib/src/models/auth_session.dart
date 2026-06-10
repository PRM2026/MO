class AuthSession {
  const AuthSession({
    required this.token,
    required this.tokenType,
    this.userId,
    this.username,
    this.email,
    this.fullName,
    this.role,
    this.twoFactorRequired = false,
  });

  final String token;
  final String tokenType;
  final int? userId;
  final String? username;
  final String? email;
  final String? fullName;
  final String? role;
  final bool twoFactorRequired;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      token: (json['token'] as String?) ?? '',
      tokenType: (json['tokenType'] as String?) ?? 'Bearer',
      userId: (json['userId'] as num?)?.toInt(),
      username: json['username'] as String?,
      email: json['email'] as String?,
      fullName: json['fullName'] as String?,
      role: json['role'] as String?,
      twoFactorRequired: json['twoFactorRequired'] as bool? ?? false,
    );
  }
}
