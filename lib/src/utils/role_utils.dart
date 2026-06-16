/// Resolves the role the app should use for navigation and portal access.
String resolveEffectiveAppRole({
  required String? role,
  required String? roleApprovalStatus,
}) {
  var normalizedRole = (role ?? 'USER').trim().toUpperCase();
  if (normalizedRole == 'HORSE_OWNER') {
    normalizedRole = 'OWNER';
  }
  final status = (roleApprovalStatus ?? 'NONE').trim().toUpperCase();

  if (status == 'PENDING' || status == 'REJECTED') {
    return 'USER';
  }

  if (status == 'APPROVED') {
    return normalizedRole;
  }

  // Login token / legacy data without explicit approval status.
  if (normalizedRole == 'JOCKEY' ||
      normalizedRole == 'REFEREE' ||
      normalizedRole == 'OWNER' ||
      normalizedRole == 'SPECTATOR' ||
      normalizedRole == 'ADMIN') {
    return normalizedRole;
  }

  return 'USER';
}

bool hasDedicatedPortal(String role) {
  return switch (role.toUpperCase()) {
    'JOCKEY' ||
    'REFEREE' ||
    'OWNER' ||
    'HORSE_OWNER' ||
    'SPECTATOR' =>
      true,
    _ => false,
  };
}

String normalizePortalRole(String role) {
  return switch (role.toUpperCase()) {
    'HORSE_OWNER' => 'OWNER',
    final value => value,
  };
}
