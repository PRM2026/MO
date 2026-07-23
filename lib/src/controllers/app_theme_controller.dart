import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppThemeController extends ChangeNotifier {
  AppThemeController({SharedPreferences? preferences})
    : _preferences = preferences;

  static const _preferenceKey = 'app_theme_mode';

  SharedPreferences? _preferences;
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  Future<SharedPreferences> get _prefs async {
    return _preferences ??= await SharedPreferences.getInstance();
  }

  Future<void> load() async {
    final storedMode = (await _prefs).getString(_preferenceKey);
    final nextMode = switch (storedMode) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    if (_themeMode == nextMode) return;
    _themeMode = nextMode;
    notifyListeners();
  }

  Future<void> setDarkMode(bool enabled) async {
    final nextMode = enabled ? ThemeMode.dark : ThemeMode.light;
    if (_themeMode != nextMode) {
      _themeMode = nextMode;
      notifyListeners();
    }
    await (await _prefs).setString(_preferenceKey, enabled ? 'dark' : 'light');
  }
}

class AppThemeScope extends InheritedNotifier<AppThemeController> {
  const AppThemeScope({
    required AppThemeController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static AppThemeController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppThemeScope>();
    assert(scope != null, 'AppThemeScope was not found in the widget tree.');
    return scope!.notifier!;
  }
}
