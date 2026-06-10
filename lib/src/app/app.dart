import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import '../constants/app_constants.dart';
import '../views/main_shell.dart';

import '../utils/app_messenger.dart';

class HorseRacingApp extends StatelessWidget {
  const HorseRacingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      scaffoldMessengerKey: AppMessenger.key,
      home: const MainShell(),
    );
  }
}
