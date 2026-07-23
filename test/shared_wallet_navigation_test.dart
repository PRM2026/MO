import 'package:flutter_test/flutter_test.dart';
import 'package:horse_racing/src/models/owner_profile_data.dart';
import 'package:horse_racing/src/models/user_profile.dart';
import 'package:horse_racing/src/views/jockey/jockey_wallet_screen.dart';

void main() {
  test('owner profile exposes wallet and payment action', () {
    final profile = OwnerProfileData.fromUserProfile(
      const UserProfile(role: 'OWNER'),
    );

    expect(
      profile.settings.map((item) => item.title),
      contains('Ví & thanh toán'),
    );
  });

  test('shared wallet accepts role-specific labels', () {
    const wallet = JockeyWalletScreen(
      title: 'Ví khán giả',
      sectionTitle: 'Ví cược & thanh toán',
    );

    expect(wallet.title, 'Ví khán giả');
    expect(wallet.sectionTitle, 'Ví cược & thanh toán');
  });
}
