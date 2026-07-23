import 'package:flutter_test/flutter_test.dart';
import 'package:horse_racing/src/views/jockey/jockey_change_password_screen.dart';

void main() {
  test('shared password screen accepts spectator context', () {
    const screen = JockeyChangePasswordScreen(portalName: 'Khán giả');

    expect(screen.portalName, 'Khán giả');
  });
}
