import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/news_article.dart';

class NewsApiException implements Exception {
  NewsApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class NewsApiService {
  NewsApiService({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? ApiConfig.baseUrl;

  final http.Client _client;
  final String _baseUrl;

  Future<List<NewsArticle>> fetchNews({bool? featured}) async {
    final query = <String, String>{};
    if (featured != null) {
      query['featured'] = featured.toString();
    }

    final uri = Uri.parse('$_baseUrl/news').replace(queryParameters: query);
    final response = await _client.get(
      uri,
      headers: const {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw NewsApiException(
        'API lỗi ${response.statusCode}: ${response.reasonPhrase}',
      );
    }

    final decoded = jsonDecode(response.body);
    final List<dynamic> items;

    if (decoded is List<dynamic>) {
      items = decoded;
    } else if (decoded is Map<String, dynamic>) {
      final apiResponse = ApiResponse<List<dynamic>>.fromJson(
        decoded,
        (data) => data as List<dynamic>,
      );
      if (!apiResponse.success) {
        throw NewsApiException(
          apiResponse.message.isEmpty
              ? 'Không thể tải tin tức'
              : apiResponse.message,
        );
      }
      items = apiResponse.data ?? const [];
    } else {
      throw NewsApiException('Phản hồi tin tức không hợp lệ.');
    }

    return items
        .whereType<Map<String, dynamic>>()
        .map(NewsArticle.fromJson)
        .where((article) => featured == null || article.isFeatured == featured)
        .toList();
  }

  Future<NewsArticle> fetchNewsDetail(String id) async {
    final uri = Uri.parse('$_baseUrl/news/$id');
    final response = await _client.get(
      uri,
      headers: const {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw NewsApiException(
        'API lỗi ${response.statusCode}: ${response.reasonPhrase}',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final apiResponse = ApiResponse<NewsArticle>.fromJson(
      body,
      (data) => NewsArticle.fromJson(data as Map<String, dynamic>),
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw NewsApiException(
        apiResponse.message.isEmpty
            ? 'Không tìm thấy bài viết'
            : apiResponse.message,
      );
    }

    return apiResponse.data!;
  }
}
