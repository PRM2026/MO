import 'package:flutter/material.dart';

import 'admin_ui.dart';

Future<bool> showAdminConfirm(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Xác nhận',
  bool danger = false,
}) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AdminPalette.navyLight,
          title: Text(title, style: const TextStyle(color: Colors.white)),
          content: Text(
            message,
            style: const TextStyle(color: AdminPalette.muted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: danger
                    ? AdminPalette.danger
                    : AdminPalette.gold,
                foregroundColor: danger ? Colors.white : AdminPalette.navy,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: Text(confirmLabel),
            ),
          ],
        ),
      ) ??
      false;
}

Future<String?> showAdminPrompt(
  BuildContext context, {
  required String title,
  required String label,
  String? initialValue,
  bool required = true,
  int maxLines = 3,
}) async {
  final controller = TextEditingController(text: initialValue);
  final result = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AdminPalette.navyLight,
      title: Text(title, style: const TextStyle(color: Colors.white)),
      content: TextField(
        controller: controller,
        autofocus: true,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AdminPalette.muted),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: AdminPalette.line),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: AdminPalette.gold),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AdminPalette.gold,
            foregroundColor: AdminPalette.navy,
          ),
          onPressed: () {
            final value = controller.text.trim();
            if (required && value.isEmpty) return;
            Navigator.pop(context, value);
          },
          child: const Text('Lưu'),
        ),
      ],
    ),
  );
  controller.dispose();
  return result;
}

void showAdminMessage(
  BuildContext context,
  String message, {
  bool error = false,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? AdminPalette.danger : AdminPalette.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
}
