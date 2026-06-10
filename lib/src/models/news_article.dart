import '../utils/image_url_resolver.dart';

class NewsArticle {
  const NewsArticle({
    required this.id,
    required this.title,
    required this.summary,
    required this.imageUrl,
    required this.dateLabel,
    required this.category,
    this.leftBadge = 'Kết quả đua',
    this.isFeatured = false,
    this.content,
  });

  final String id;
  final String title;
  final String summary;
  final String imageUrl;
  final String dateLabel;
  final String category;
  final String leftBadge;
  final bool isFeatured;
  final String? content;

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    final category = (json['category'] as String?)?.trim() ?? 'Tin tức';
    final publishedAt = json['publishedAt'] as String?;
    final createdAt = json['createdAt'] as String?;

    return NewsArticle(
      id: '${json['id']}',
      title: (json['title'] as String?)?.trim() ?? '',
      summary: (json['summary'] as String?)?.trim() ?? '',
      imageUrl: ImageUrlResolver.resolve(json['imageUrl'] as String?),
      dateLabel: _formatDate(publishedAt ?? createdAt),
      category: category,
      leftBadge: category,
      isFeatured: json['featured'] as bool? ?? false,
      content: json['content'] as String?,
    );
  }

  static String _formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '';
    try {
      final date = DateTime.parse(isoDate).toLocal();
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      return '$day/$month/${date.year}';
    } catch (_) {
      return isoDate;
    }
  }
}
