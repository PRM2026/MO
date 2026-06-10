import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/news_colors.dart';
import '../../models/news_article.dart';
import 'news_network_image.dart';

class FeaturedNewsCard extends StatelessWidget {
  const FeaturedNewsCard({
    super.key,
    required this.article,
    required this.width,
    this.onReadMore,
  });

  final NewsArticle article;
  final double width;
  final VoidCallback? onReadMore;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 4,
        shadowColor: NewsColors.navy.withValues(alpha: 0.12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
          side: BorderSide(color: NewsColors.border.withValues(alpha: 0.9)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 192,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fill(
                    child: NewsNetworkImage(imageUrl: article.imageUrl),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: _Badge(
                      label: article.leftBadge,
                      color: NewsColors.gold,
                    ),
                  ),
                  const Positioned(
                    top: 12,
                    right: 12,
                    child: _Badge(
                      label: 'Nổi bật',
                      color: NewsColors.featuredBadge,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: NewsColors.textMuted.withValues(alpha: 0.8),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        article.dateLabel,
                        style: TextStyle(
                          fontSize: 12,
                          color: NewsColors.textMuted.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: NewsColors.navy,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    article.summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: NewsColors.textMuted,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Divider(color: NewsColors.border.withValues(alpha: 0.6)),
                  const SizedBox(height: AppSpacing.md),
                  InkWell(
                    onTap: onReadMore,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Đọc thêm',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: NewsColors.gold,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: NewsColors.gold,
                        ),
                      ],
                    ),
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

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class FeaturedNewsSection extends StatelessWidget {
  const FeaturedNewsSection({
    super.key,
    required this.articles,
    this.onReadMore,
  });

  final List<NewsArticle> articles;
  final ValueChanged<NewsArticle>? onReadMore;

  @override
  Widget build(BuildContext context) {
    final cardWidth = MediaQuery.sizeOf(context).width * 0.85;

    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('⭐', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text(
              'TIN TỨC NỔI BẬT',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: NewsColors.navy,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(width: 8),
            Text('⭐', style: TextStyle(fontSize: 24)),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          height: 450,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: articles.length,
            separatorBuilder: (context, index) =>
                const SizedBox(width: AppSpacing.lg),
            itemBuilder: (context, index) {
              final article = articles[index];
              return FeaturedNewsCard(
                article: article,
                width: cardWidth,
                onReadMore: () => onReadMore?.call(article),
              );
            },
          ),
        ),
      ],
    );
  }
}
