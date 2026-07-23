import 'package:flutter/material.dart';

import '../constants/referee_colors.dart';

enum PasswordStrength { weak, medium, strong }

abstract final class PasswordStrengthUtils {
  static int score(String password) {
    var result = 0;
    if (password.length >= 8) result++;
    if (RegExp('[A-Z]').hasMatch(password) &&
        RegExp('[a-z]').hasMatch(password)) {
      result++;
    }
    if (RegExp('[0-9]').hasMatch(password)) result++;
    return result;
  }

  static PasswordStrength evaluate(String password) {
    final value = score(password);
    if (value >= 3) return PasswordStrength.strong;
    if (value == 2) return PasswordStrength.medium;
    return PasswordStrength.weak;
  }

  static bool meetsRequirements(String password) => score(password) >= 3;

  static String label(PasswordStrength strength) {
    return switch (strength) {
      PasswordStrength.weak => 'Yếu',
      PasswordStrength.medium => 'Trung bình',
      PasswordStrength.strong => 'Mạnh',
    };
  }

  static Color color(PasswordStrength strength) {
    return switch (strength) {
      PasswordStrength.weak => RefereeColors.statusRed,
      PasswordStrength.medium => RefereeColors.tertiary,
      PasswordStrength.strong => RefereeColors.successEmerald,
    };
  }
}
