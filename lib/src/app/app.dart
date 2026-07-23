import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import '../constants/app_constants.dart';
import '../controllers/app_theme_controller.dart';
import '../views/main_shell.dart';

import '../utils/app_messenger.dart';

class HorseRacingApp extends StatefulWidget {
  const HorseRacingApp({super.key});

  @override
  State<HorseRacingApp> createState() => _HorseRacingAppState();
}

class _HorseRacingAppState extends State<HorseRacingApp> {
  late final AppThemeController _themeController;

  @override
  void initState() {
    super.initState();
    _themeController = AppThemeController()..load();
  }

  @override
  void dispose() {
    _themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppThemeScope(
      controller: _themeController,
      child: AnimatedBuilder(
        animation: _themeController,
        builder: (context, _) => MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: _themeController.themeMode,
          themeAnimationDuration: const Duration(milliseconds: 220),
          themeAnimationCurve: Curves.easeOutCubic,
          scaffoldMessengerKey: AppMessenger.key,
          home: const MainShell(),
        ),
      ),
    );
  }
}
