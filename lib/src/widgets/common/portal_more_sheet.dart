import 'package:flutter/material.dart';

import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import 'theme_mode_toggle.dart';

class PortalMoreAction {
  const PortalMoreAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final bool destructive;
}

Future<void> showPortalMoreSheet(
  BuildContext context, {
  required String portalName,
  required List<PortalMoreAction> actions,
}) {
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            child: Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            portalName,
            style: AppTypography.headlineSm(
              Theme.of(sheetContext).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tất cả chức năng',
            style: AppTypography.bodySm(
              Theme.of(sheetContext).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          const ThemeModeSwitchTile(compact: true),
          const SizedBox(height: 14),
          Flexible(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final action in actions)
                    SizedBox(
                      width: (MediaQuery.sizeOf(context).width - 52) / 2,
                      child: _PortalMoreTile(
                        action: action,
                        onPressed: () {
                          Navigator.of(sheetContext).pop();
                          action.onTap();
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _PortalMoreTile extends StatelessWidget {
  const _PortalMoreTile({required this.action, required this.onPressed});

  final PortalMoreAction action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = action.destructive ? RefereeColors.statusRed : scheme.primary;
    return Material(
      color: scheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          constraints: const BoxConstraints(minHeight: 112),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: scheme.outlineVariant),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(action.icon, color: color, size: 26),
              const SizedBox(height: 18),
              Text(
                action.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyMd(
                  scheme.onSurface,
                ).copyWith(fontWeight: FontWeight.w700),
              ),
              if (action.subtitle != null)
                Text(
                  action.subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySm(scheme.onSurfaceVariant),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
