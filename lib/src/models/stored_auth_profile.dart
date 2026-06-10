class StoredAuthProfile {
  const StoredAuthProfile({
    this.token,
    this.tokenType,
    this.email,
    this.fullName,
    this.role,
  });

  final String? token;
  final String? tokenType;
  final String? email;
  final String? fullName;
  final String? role;

  String get bearerToken {
    if (token == null || token!.isEmpty) return '—';
    final type = tokenType?.trim();
    if (type == null || type.isEmpty) return token!;
    return '$type $token';
  }
}
