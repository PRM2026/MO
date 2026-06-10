import 'package:flutter/foundation.dart';

import '../models/news_article.dart';
import '../repositories/news_repository.dart';

class NewsViewModel extends ChangeNotifier {
  NewsViewModel({NewsRepository? repository})
      : _repository = repository ?? NewsRepository();

  final NewsRepository _repository;

  bool isLoading = false;
  bool isRefreshing = false;
  String? errorMessage;
  String searchQuery = '';

  List<NewsArticle> _featuredNews = [];
  List<NewsArticle> _latestNews = [];

  List<NewsArticle> get featuredNews => _featuredNews;

  List<NewsArticle> get latestNews {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) return _latestNews;
    return _latestNews
        .where(
          (article) =>
              article.title.toLowerCase().contains(query) ||
              article.category.toLowerCase().contains(query) ||
              article.summary.toLowerCase().contains(query),
        )
        .toList();
  }

  Future<void> loadNews() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.fetchFeaturedNews(),
        _repository.fetchLatestNews(),
      ]);
      _featuredNews = results[0];
      _latestNews = results[1];
    } catch (error) {
      errorMessage = 'Không thể tải tin tức. Hãy bật BE và thử lại.';
      if (kDebugMode) {
        errorMessage = '$errorMessage\n($error)';
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshNews() async {
    isRefreshing = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.fetchFeaturedNews(),
        _repository.fetchLatestNews(),
      ]);
      _featuredNews = results[0];
      _latestNews = results[1];
      errorMessage = null;
    } catch (error) {
      errorMessage = 'Không thể tải tin tức. Hãy bật BE và thử lại.';
      if (kDebugMode) {
        errorMessage = '$errorMessage\n($error)';
      }
    } finally {
      isRefreshing = false;
      notifyListeners();
    }
  }

  void updateSearch(String value) {
    searchQuery = value;
    notifyListeners();
  }
}
