import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horse_racing/src/widgets/owner/owner_bottom_nav.dart';
import 'package:horse_racing/src/widgets/referee/referee_bottom_nav.dart';

void main() {
  testWidgets('owner portal exposes registrations and complete menu', (
    tester,
  ) async {
    OwnerTab? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: OwnerBottomNav(
            currentTab: OwnerTab.home,
            onTabSelected: (tab) => selected = tab,
          ),
        ),
      ),
    );

    expect(find.text('Đăng ký'), findsOneWidget);
    expect(find.text('Thêm'), findsOneWidget);
    await tester.tap(find.text('Đăng ký'));
    expect(selected, OwnerTab.registrations);
  });

  testWidgets('referee portal keeps violations directly accessible', (
    tester,
  ) async {
    RefereeTab? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: RefereeBottomNav(
            currentTab: RefereeTab.overview,
            onTabSelected: (tab) => selected = tab,
          ),
        ),
      ),
    );

    expect(find.text('Vi phạm'), findsOneWidget);
    await tester.tap(find.text('Vi phạm'));
    expect(selected, RefereeTab.violations);
  });
}
