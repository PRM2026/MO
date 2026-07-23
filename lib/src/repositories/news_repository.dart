import '../models/news_article.dart';
import '../services/news_api_service.dart';

class NewsRepository {
  NewsRepository({NewsApiService? apiService})
    : _apiService = apiService ?? NewsApiService();

  final NewsApiService _apiService;

  Future<List<NewsArticle>> fetchFeaturedNews() =>
      _apiService.fetchNews(featured: true);

  Future<List<NewsArticle>> fetchLatestNews() =>
      _apiService.fetchNews(featured: false);
}
