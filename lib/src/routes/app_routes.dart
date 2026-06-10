import 'package:flutter/material.dart';

import '../views/login_screen.dart';
import '../views/main_shell.dart';
import '../views/register_screen.dart';
import '../widgets/home/home_bottom_nav.dart';

abstract final class AppRoutes {
  static Route<void> login() {
    return MaterialPageRoute<void>(
      builder: (_) => const LoginScreen(),
    );
  }

  static Route<void> register() {
    return MaterialPageRoute<void>(
      builder: (_) => const RegisterScreen(),
    );
  }

  static Route<void> main({HomeTab initialTab = HomeTab.home}) {
    return MaterialPageRoute<void>(
      builder: (_) => MainShell(initialTab: initialTab),
    );
  }

  static Route<void> home() => main();

  static Route<void> news() => main(initialTab: HomeTab.news);

  static Route<void> about() => main(initialTab: HomeTab.about);

  static void openLogin(BuildContext context) {
    Navigator.of(context).push(login());
  }

  static void openRegister(BuildContext context) {
    Navigator.of(context).push(register());
  }

  static void openHome(BuildContext context) {
    if (MainShell.of(context) != null) {
      MainShell.selectTab(context, HomeTab.home);
      return;
    }
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }
    Navigator.of(context).pushReplacement(main());
  }

  static void openNews(BuildContext context) {
    _switchTabOrReplace(context, HomeTab.news);
  }

  static void openAbout(BuildContext context) {
    _switchTabOrReplace(context, HomeTab.about);
  }

  static void _switchTabOrReplace(BuildContext context, HomeTab tab) {
    if (MainShell.of(context) != null) {
      MainShell.selectTab(context, tab);
      return;
    }
    Navigator.of(context).pushReplacement(main(initialTab: tab));
  }
}
