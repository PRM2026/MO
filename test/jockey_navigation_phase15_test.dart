import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horse_racing/src/widgets/jockey/jockey_bottom_nav.dart';
import 'package:horse_racing/src/widgets/jockey/jockey_profile_widgets.dart';

void main() {
  testWidgets('bottom nav uses assignments instead of profile for last tab', (
    tester,
  ) async {
    JockeyTab? selectedTab;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: JockeyBottomNav(
            currentTab: JockeyTab.dashboard,
            onTabSelected: (tab) => selectedTab = tab,
          ),
        ),
      ),
    );

    expect(find.text('Phân công'), findsOneWidget);
    expect(find.text('Hồ sơ'), findsNothing);

    await tester.tap(find.text('Phân công'));
    await tester.pump();

    expect(selectedTab, JockeyTab.assignments);
  });

  testWidgets('profile actions expose wallet and notifications entries', (
    tester,
  ) async {
    var walletTapped = false;
    var notificationsTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: JockeyProfileActionsCard(
            isLoggingOut: false,
            onEdit: () {},
            onWallet: () => walletTapped = true,
            onNotifications: () => notificationsTapped = true,
            onChangePassword: () {},
            onLogout: () {},
          ),
        ),
      ),
    );

    expect(find.text('Chinh sua ho so'), findsOneWidget);
    expect(find.text('Vi cua toi'), findsOneWidget);
    expect(find.text('Thong bao'), findsOneWidget);
    expect(find.text('Bao mat & Mat khau'), findsOneWidget);
    expect(find.text('Dang xuat'), findsOneWidget);

    await tester.tap(find.text('Vi cua toi'));
    await tester.tap(find.text('Thong bao'));
    await tester.pump();

    expect(walletTapped, isTrue);
    expect(notificationsTapped, isTrue);
  });
}
