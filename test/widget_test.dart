import 'package:flutter_test/flutter_test.dart';

import 'package:horse_racing/src/app/app.dart';

void main() {
  testWidgets('Login screen renders key elements', (WidgetTester tester) async {
    await tester.pumpWidget(const HorseRacingApp());

    expect(find.text('Đăng nhập'), findsOneWidget);
    expect(find.text('Ghi nhớ đăng nhập'), findsOneWidget);
    expect(find.text('Google'), findsOneWidget);
  });
}
