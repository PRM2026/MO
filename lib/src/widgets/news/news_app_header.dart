import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/news_colors.dart';

class NewsAppHeader extends StatelessWidget implements PreferredSizeWidget {
  const NewsAppHeader({super.key, this.onMenuTap});

  final VoidCallback? onMenuTap;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: NewsColors.surface,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: NewsColors.navy.withValues(alpha: 0.08),
      title: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: NewsColors.gold,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(Icons.paid, color: Colors.white, size: 24),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'HORSE RACING',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: NewsColors.navy,
                  height: 1,
                ),
              ),
              Text(
                'CHAMPIONSHIP',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                  color: NewsColors.gold,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: onMenuTap,
          icon: const Icon(Icons.menu, color: NewsColors.navy, size: 28),
        ),
      ],
    );
  }
}
