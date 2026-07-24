import 'package:flutter/material.dart';

abstract final class AdminPalette {
  static const navy = Color(0xFF081528);
  static const navyLight = Color(0xFF10233D);
  static const card = Color(0xFF12243C);
  static const gold = Color(0xFFDDA50E);
  static const goldLight = Color(0xFFF7CB52);
  static const muted = Color(0xFF95A4B9);
  static const line = Color(0xFF263A54);
  static const success = Color(0xFF34D399);
  static const danger = Color(0xFFF87171);
  static const info = Color(0xFF38BDF8);
}

class AdminPage extends StatelessWidget {
  const AdminPage({
    required this.title,
    required this.subtitle,
    required this.child,
    super.key,
    this.action,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: scheme.surface,
      child: SafeArea(
        top: false,
        child: RefreshIndicator(
          color: AdminPalette.gold,
          onRefresh: () async {
            final state = context
                .findAncestorStateOfType<AdminRefreshHostState>();
            await state?.refresh();
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 27,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: AdminPalette.muted,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (action != null) ...[const SizedBox(width: 12), action!],
                ],
              ),
              const SizedBox(height: 22),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class AdminRefreshHost extends StatefulWidget {
  const AdminRefreshHost({
    required this.onRefresh,
    required this.child,
    super.key,
  });

  final Future<void> Function() onRefresh;
  final Widget child;

  @override
  State<AdminRefreshHost> createState() => AdminRefreshHostState();
}

class AdminRefreshHostState extends State<AdminRefreshHost> {
  Future<void> refresh() => widget.onRefresh();

  @override
  Widget build(BuildContext context) => widget.child;
}

class AdminCard extends StatelessWidget {
  const AdminCard({required this.child, super.key, this.padding});

  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminPalette.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AdminPalette.line),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class AdminStatCard extends StatelessWidget {
  const AdminStatCard({
    required this.label,
    required this.value,
    required this.icon,
    super.key,
    this.color = AdminPalette.gold,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    maxLines: 1,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: const TextStyle(
                    color: AdminPalette.muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AdminStatusChip extends StatelessWidget {
  const AdminStatusChip(this.status, {super.key});

  final String status;

  Color get _color {
    final value = status.toUpperCase();
    if (value.contains('APPROV') ||
        value.contains('ACTIVE') ||
        value.contains('OPEN') ||
        value.contains('HOÀN') ||
        value.contains('ĐÃ DUYỆT')) {
      return AdminPalette.success;
    }
    if (value.contains('REJECT') ||
        value.contains('CANCEL') ||
        value.contains('SUSPEND') ||
        value.contains('TỪ CHỐI')) {
      return AdminPalette.danger;
    }
    if (value.contains('PENDING') ||
        value.contains('DRAFT') ||
        value.contains('CHỜ')) {
      return AdminPalette.goldLight;
    }
    return AdminPalette.info;
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        status.isEmpty ? 'Chưa cập nhật' : status,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class AdminPrimaryButton extends StatelessWidget {
  const AdminPrimaryButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.busy = false,
    this.danger = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool busy;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final background = danger ? AdminPalette.danger : AdminPalette.gold;
    return FilledButton.icon(
      onPressed: busy ? null : onPressed,
      icon: busy
          ? const SizedBox.square(
              dimension: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon ?? Icons.arrow_forward_rounded, size: 18),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: background,
        foregroundColor: danger ? Colors.white : AdminPalette.navy,
        minimumSize: const Size(0, 42),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class AdminEmptyState extends StatelessWidget {
  const AdminEmptyState({
    required this.message,
    super.key,
    this.icon = Icons.inbox_outlined,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 35),
        child: Column(
          children: [
            Icon(icon, color: AdminPalette.muted, size: 44),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AdminPalette.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminLoading extends StatelessWidget {
  const AdminLoading({super.key});

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 80),
    child: Center(child: CircularProgressIndicator(color: AdminPalette.gold)),
  );
}

class AdminErrorCard extends StatelessWidget {
  const AdminErrorCard({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            color: AdminPalette.danger,
            size: 42,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 14),
          AdminPrimaryButton(
            label: 'Thử lại',
            icon: Icons.refresh_rounded,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}

String adminText(Map<String, dynamic> map, String key, [String fallback = '']) {
  final value = map[key];
  if (value == null) return fallback;
  return value.toString();
}

num adminNumber(Map<String, dynamic> map, String key) {
  final value = map[key];
  if (value is num) return value;
  return num.tryParse('$value') ?? 0;
}

String formatAdminMoney(Object? value) {
  final number = value is num ? value : num.tryParse('$value') ?? 0;
  final digits = number.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  return '${buffer.toString()} ₫';
}
