import 'package:flutter_test/flutter_test.dart';
import 'package:horse_racing/src/models/owner_profile_data.dart';
import 'package:horse_racing/src/models/referee_profile_data.dart';
import 'package:horse_racing/src/models/user_profile.dart';
import 'package:horse_racing/src/views/jockey/jockey_notifications_screen.dart';

void main() {
  test('owner and referee profiles expose notification center', () {
    final owner = OwnerProfileData.fromUserProfile(
      const UserProfile(role: 'OWNER'),
    );
    final referee = RefereeProfileData.sample();

    expect(owner.settings.map((item) => item.title), contains('Thông báo'));
    expect(referee.settings.map((item) => item.title), contains('Thông báo'));
  });

  test('shared notification center accepts role-specific title', () {
    const screen = JockeyNotificationsScreen(title: 'Thông báo khán giả');

    expect(screen.title, 'Thông báo khán giả');
  });
}
