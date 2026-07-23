import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horse_racing/src/controllers/app_theme_controller.dart';
import 'package:horse_racing/src/widgets/common/theme_mode_toggle.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('loads and persists the selected theme mode', () async {
    final controller = AppThemeController();

    await controller.load();
    expect(controller.themeMode, ThemeMode.system);

    await controller.setDarkMode(true);
    expect(controller.themeMode, ThemeMode.dark);

    final restored = AppThemeController();
    await restored.load();
    expect(restored.themeMode, ThemeMode.dark);

    await restored.setDarkMode(false);
    expect(restored.themeMode, ThemeMode.light);
  });

  testWidgets('theme switch changes the Material theme', (tester) async {
    final controller = AppThemeController();

    Widget buildApp() {
      return AppThemeScope(
        controller: controller,
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) => MaterialApp(
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: controller.themeMode,
            home: const Scaffold(body: ThemeModeSwitchTile()),
          ),
        ),
      );
    }

    await tester.pumpWidget(buildApp());
    expect(find.text('Đang dùng giao diện sáng'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('theme-mode-switch')));
    await tester.pumpAndSettle();

    expect(controller.themeMode, ThemeMode.dark);
    expect(find.text('Đang dùng giao diện tối'), findsOneWidget);
  });
}
