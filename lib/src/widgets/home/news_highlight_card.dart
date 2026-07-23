import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_theme_tokens.dart';
import '../../models/news_highlight.dart';

class NewsHighlightCard extends StatelessWidget {
  const NewsHighlightCard({super.key, required this.article});

  final NewsHighlight article;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 256,
      child: Card(
        color: AppColors.surfaceContainer,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  article.imageUrl,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.category,
                      style: AppTypography.labelCaps(
                        AppColors.primary,
                      ).copyWith(fontSize: 11),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyMd(
                        AppColors.onSurface,
                      ).copyWith(fontWeight: FontWeight.w500, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
