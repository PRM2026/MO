import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';
import '../../constants/referee_colors.dart';
import '../../models/notification_response.dart';
import '../../utils/date_format.dart';
import '../../viewmodels/jockey_notifications_viewmodel.dart';
import '../referee/referee_glass_card.dart';
import 'jockey_state_widgets.dart';

class JockeyNotificationHeader extends StatelessWidget {
  const JockeyNotificationHeader({
    super.key,
    required this.unreadCount,
    required this.isMarkingAll,
    required this.onMarkAll,
  });

  final int unreadCount;
  final bool isMarkingAll;
  final VoidCallback? onMarkAll;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final title = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TRUNG TÂM THÔNG BÁO',
              style: AppTypography.labelCaps(RefereeColors.championshipGold),
            ),
            const SizedBox(height: 4),
            Text(
              'Thông báo của tôi',
              style: AppTypography.displayLg(
                RefereeColors.onSurface,
              ).copyWith(fontSize: 28),
            ),
            const SizedBox(height: 6),
            Text(
              unreadCount == 0
                  ? 'Bạn đã đọc tất cả thông báo.'
                  : '$unreadCount thông báo chưa đọc',
              key: const Key('jockey-notification-unread-summary'),
              style: AppTypography.bodyMd(RefereeColors.onSurfaceVariant),
            ),
          ],
        );

        final action = OutlinedButton.icon(
          key: const Key('jockey-notification-mark-all'),
          onPressed: onMarkAll,
          icon: isMarkingAll
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.done_all_outlined),
          label: Text(
            isMarkingAll ? 'Đang cập nhật...' : 'Đánh dấu tất cả đã đọc',
          ),
        );

        if (constraints.maxWidth >= 720) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: title),
              const SizedBox(width: AppSpacing.md),
              action,
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            title,
            const SizedBox(height: AppSpacing.md),
            action,
          ],
        );
      },
    );
  }
}

class JockeyNotificationFilters extends StatelessWidget {
  const JockeyNotificationFilters({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final JockeyNotificationFilter selected;
  final ValueChanged<JockeyNotificationFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final filter in JockeyNotificationFilter.values)
          ChoiceChip(
            key: Key('jockey-notification-filter-${filter.name}'),
            selected: selected == filter,
            label: Text(filter.label),
            onSelected: (_) => onSelected(filter),
          ),
      ],
    );
  }
}

class JockeyNotificationList extends StatelessWidget {
  const JockeyNotificationList({
    super.key,
    required this.notifications,
    required this.processingIds,
    required this.onTap,
  });

  final List<NotificationResponse> notifications;
  final Set<String> processingIds;
  final ValueChanged<NotificationResponse> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < notifications.length; index++) ...[
          JockeyNotificationCard(
            item: notifications[index],
            isProcessing: processingIds.contains(notifications[index].id),
            onTap: () => onTap(notifications[index]),
          ),
          if (index < notifications.length - 1)
            const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class JockeyNotificationCard extends StatelessWidget {
  const JockeyNotificationCard({
    super.key,
    required this.item,
    required this.isProcessing,
    required this.onTap,
  });

  final NotificationResponse item;
  final bool isProcessing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final unread = !item.isRead;
    final color = _notificationColor(item.type);
    return RefereeGlassCard(
      padding: EdgeInsets.zero,
      highlighted: unread,
      onTap: isProcessing ? null : onTap,
      child: Padding(
        key: Key('jockey-notification-${item.id}'),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: isProcessing
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: color,
                      ),
                    )
                  : Icon(_notificationIcon(item.type), color: color),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: AppTypography.bodyMd(RefereeColors.onSurface)
                              .copyWith(
                                fontWeight: unread
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                              ),
                        ),
                      ),
                      if (unread)
                        Container(
                          key: Key('jockey-notification-unread-${item.id}'),
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: RefereeColors.championshipGold,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  if (item.message.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      item.message,
                      style: AppTypography.bodySm(
                        RefereeColors.onSurfaceVariant,
                      ).copyWith(height: 1.45),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    formatDisplayDateTime(item.createdAt?.toIso8601String()),
                    style: AppTypography.labelCaps(
                      RefereeColors.onSurfaceVariant,
                    ).copyWith(fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class JockeyNotificationInfoBanner extends StatelessWidget {
  const JockeyNotificationInfoBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: RefereeColors.statusRed.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: RefereeColors.statusRed.withValues(alpha: 0.25),
        ),
      ),
      child: Text(
        message,
        style: AppTypography.bodySm(RefereeColors.statusRed),
      ),
    );
  }
}

class JockeyNotificationLoadMore extends StatelessWidget {
  const JockeyNotificationLoadMore({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: OutlinedButton.icon(
        key: const Key('jockey-notification-load-more'),
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.expand_more),
        label: Text(isLoading ? 'Đang tải...' : 'Tải thêm'),
      ),
    );
  }
}

class JockeyNotificationEmptyState extends StatelessWidget {
  const JockeyNotificationEmptyState({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return JockeyStateMessage(
      message: message,
      icon: Icons.notifications_none_outlined,
    );
  }
}

IconData _notificationIcon(String? type) {
  if (type?.startsWith('INVITATION_') == true) {
    return Icons.mail_outline;
  }
  if (type?.startsWith('DEPOSIT_') == true) {
    return Icons.add_card_outlined;
  }
  if (type?.startsWith('WITHDRAWAL_') == true) {
    return Icons.account_balance_outlined;
  }
  if (type?.startsWith('RACE_') == true) {
    return Icons.emoji_events_outlined;
  }
  if (type?.startsWith('PRIZE_') == true) {
    return Icons.workspace_premium_outlined;
  }
  if (type == 'ADMIN_ANNOUNCEMENT') {
    return Icons.campaign_outlined;
  }
  return Icons.notifications_outlined;
}

Color _notificationColor(String? type) {
  if (type?.contains('FAILED') == true ||
      type?.contains('REJECTED') == true ||
      type?.contains('CANCELLED') == true ||
      type?.contains('UNPAID') == true) {
    return RefereeColors.statusRed;
  }
  if (type?.contains('PAID') == true ||
      type?.contains('APPROVED') == true ||
      type?.contains('ACCEPTED') == true) {
    return RefereeColors.successEmerald;
  }
  return RefereeColors.championshipGold;
}
