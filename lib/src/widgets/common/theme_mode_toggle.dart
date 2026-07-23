import 'package:flutter/material.dart';

import '../../controllers/app_theme_controller.dart';

class ThemeModeIconButton extends StatelessWidget {
  const ThemeModeIconButton({super.key, this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return IconButton(
      key: const ValueKey('theme-mode-icon-button'),
      tooltip: isDark
          ? 'Chuyển sang giao diện sáng'
          : 'Chuyển sang giao diện tối',
      onPressed: () => AppThemeScope.of(context).setDarkMode(!isDark),
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),
        child: Icon(
          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          key: ValueKey(isDark),
          color: color ?? Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}

class ThemeModeSwitchTile extends StatelessWidget {
  const ThemeModeSwitchTile({
    super.key,
    this.title = 'Chế độ tối',
    this.subtitle = 'Đổi giao diện sáng hoặc tối',
    this.compact = false,
  });

  final String title;
  final String subtitle;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      label: 'Chuyển chế độ giao diện',
      toggled: isDark,
      child: Material(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        child: SwitchListTile.adaptive(
          key: const ValueKey('theme-mode-switch'),
          contentPadding: EdgeInsets.symmetric(
            horizontal: compact ? 12 : 16,
            vertical: compact ? 2 : 5,
          ),
          secondary: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Icon(
              isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              key: ValueKey(isDark),
              color: scheme.primary,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: scheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          subtitle: Text(
            isDark ? 'Đang dùng giao diện tối' : 'Đang dùng giao diện sáng',
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
          value: isDark,
          activeThumbColor: scheme.primary,
          onChanged: AppThemeScope.of(context).setDarkMode,
        ),
      ),
    );
  }
}
