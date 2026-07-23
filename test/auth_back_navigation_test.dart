import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horse_racing/src/views/forgot_password_screen.dart';
import 'package:horse_racing/src/views/login_screen.dart';
import 'package:horse_racing/src/views/register_screen.dart';

void main() {
  for (final screen in <Widget>[
    const LoginScreen(),
    const RegisterScreen(),
    const ForgotPasswordScreen(),
  ]) {
    testWidgets('${screen.runtimeType} exposes a top back action', (
      tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: screen));

      expect(find.byKey(const ValueKey('auth-back-button')), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    });
  }
}
