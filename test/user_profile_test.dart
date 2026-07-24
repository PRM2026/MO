import 'package:flutter_test/flutter_test.dart';
import 'package:horse_racing/src/models/user_profile.dart';

void main() {
  test('UserProfile accepts a Railway UUID without losing the role', () {
    final profile = UserProfile.fromJson({
      'id': '6a45ffa2f39ce4024ca749e9',
      'email': 'admin@hr.vn',
      'role': 'ADMIN',
      'roleApprovalStatus': 'APPROVED',
    });

    expect(profile.role, 'ADMIN');
    expect(profile.effectiveAppRole, 'ADMIN');
  });
}
