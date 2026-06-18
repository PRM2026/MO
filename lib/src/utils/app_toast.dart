import 'package:flutter/material.dart';

import 'app_messenger.dart';

abstract final class AppToast {
  static void showSuccess(
    BuildContext context,
    String message, {
    String? subtitle,
  }) {
    if (subtitle == null) {
      _show(
        message,
        icon: Icons.check_circle_outline,
        backgroundColor: const Color(0xFF2E7D32),
      );
      return;
    }

    final messenger = AppMessenger.key.currentState;
    final ctx = AppMessenger.key.currentContext;
    if (messenger == null || ctx == null) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0x3310B981),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Color(0xFF10B981)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFFC5C6CD),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xE60C1D36),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0x3310B981)),
          ),
          duration: const Duration(seconds: 3),
          elevation: 8,
        ),
      );
  }

  static void showError(BuildContext context, String message) {
    _show(
      message,
      icon: Icons.error_outline,
      backgroundColor: const Color(0xFFC62828),
    );
  }

  static void _show(
    String message, {
    required IconData icon,
    required Color backgroundColor,
  }) {
    final messenger = AppMessenger.key.currentState;
    final context = AppMessenger.key.currentContext;
    if (messenger == null || context == null) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 3),
          elevation: 4,
          dismissDirection: DismissDirection.up,
        ),
      );
  }
}
