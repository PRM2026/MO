import 'package:flutter_test/flutter_test.dart';
import 'package:horse_racing/src/models/owner_profile_data.dart';
import 'package:horse_racing/src/models/user_profile.dart';
import 'package:horse_racing/src/views/owner/owner_race_registrations_screen.dart';

void main() {
  test('owner profile exposes race registrations', () {
    final profile = OwnerProfileData.fromUserProfile(
      const UserProfile(role: 'OWNER'),
    );

    expect(
      profile.settings.map((item) => item.title),
      contains('Đăng ký cuộc đua'),
    );
  });

  test('race registration history screen is constructible', () {
    expect(const OwnerRaceRegistrationsScreen(), isNotNull);
  });
}
