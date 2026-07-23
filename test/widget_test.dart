import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horse_racing/src/widgets/home/home_app_bar.dart';
import 'package:horse_racing/src/widgets/home/home_bottom_nav.dart';

void main() {
  testWidgets('public shell bottom navigation renders guest destinations', (
    tester,
  ) async {
    HomeTab? selectedTab;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: HomeBottomNav(
            currentTab: HomeTab.home,
            isLoggedIn: false,
            onTabSelected: (tab) => selectedTab = tab,
          ),
        ),
      ),
    );

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(4));

    await tester.tap(find.byIcon(Icons.newspaper_outlined));
    await tester.pump();

    expect(selectedTab, HomeTab.news);
  });

  testWidgets('home app bar exposes a clear login action', (tester) async {
    var loginTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(appBar: HomeAppBar(onLogin: () => loginTapped = true)),
      ),
    );

    expect(find.text('Đăng nhập'), findsOneWidget);
    expect(find.byIcon(Icons.login_rounded), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('home-login-action')));
    await tester.pump();

    expect(loginTapped, isTrue);
  });

  testWidgets('home wordmark stays fully inside the app bar on iPhone width', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(appBar: HomeAppBar())),
    );

    final wordmark = find.text('Grand Championship');
    expect(wordmark, findsOneWidget);

    final wordmarkRect = tester.getRect(wordmark);
    final appBarRect = tester.getRect(find.byType(AppBar));

    expect(wordmarkRect.top, greaterThanOrEqualTo(appBarRect.top));
    expect(wordmarkRect.bottom, lessThanOrEqualTo(appBarRect.bottom - 8));
  });
}
