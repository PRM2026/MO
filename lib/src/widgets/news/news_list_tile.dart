import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../constants/news_colors.dart';
import '../../models/news_article.dart';
import 'news_network_image.dart';

class NewsListTile extends StatelessWidget {
  const NewsListTile({super.key, required this.article, this.onTap});

  final NewsArticle article;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: NewsColors.surface,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      shadowColor: NewsColors.navy.withValues(alpha: 0.06),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: NewsColors.navy.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: NewsNetworkImage(
                  imageUrl: article.imageUrl,
                  width: 96,
                  height: 96,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: SizedBox(
                  height: 96,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            article.category.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: NewsColors.gold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            article.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: NewsColors.navy,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        article.dateLabel,
                        style: TextStyle(
                          fontSize: 10,
                          color: NewsColors.textMuted.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LatestNewsSection extends StatelessWidget {
  const LatestNewsSection({
    super.key,
    required this.articles,
    this.onArticleTap,
    this.onLoadMore,
  });

  final List<NewsArticle> articles;
  final ValueChanged<NewsArticle>? onArticleTap;
  final VoidCallback? onLoadMore;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tin tức mới nhất',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: NewsColors.navy,
              ),
            ),
            Container(
              width: 48,
              height: 2,
              decoration: BoxDecoration(
                color: NewsColors.gold,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: articles.length,
          separatorBuilder: (context, index) =>
              const SizedBox(height: AppSpacing.lg),
          itemBuilder: (context, index) {
            final article = articles[index];
            return NewsListTile(
              article: article,
              onTap: () => onArticleTap?.call(article),
            );
          },
        ),
        const SizedBox(height: AppSpacing.xl),
        Center(
          child: FilledButton(
            onPressed: onLoadMore,
            style: FilledButton.styleFrom(
              backgroundColor: NewsColors.navy,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
              elevation: 3,
            ),
            child: const Text(
              'Xem thêm tin tức',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}
