import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horse_racing/src/widgets/auth/social_auth_button.dart';

void main() {
  testWidgets('Google auth button uses a stable local icon', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: SocialAuthButton(provider: SocialProvider.google)),
      ),
    );

    expect(find.byType(Image), findsNothing);
    expect(find.byIcon(Icons.g_mobiledata_rounded), findsOneWidget);
    expect(find.text('Google'), findsOneWidget);
  });
}
