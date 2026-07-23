import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:horse_racing/src/services/news_api_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('fetchNews accepts the top-level list returned by Railway', () async {
    final service = NewsApiService(
      baseUrl: 'https://api.example.test',
      client: MockClient(
        (_) async => http.Response(
          jsonEncode([
            {
              'id': 'news-1',
              'title': 'Grand Championship 2026',
              'summary': 'Tin mới nhất',
              'content': 'Nội dung',
              'imageUrl': '',
              'category': 'Giải đấu',
              'createdAt': '2026-07-24T02:00:00.000Z',
              'featured': true,
            },
          ]),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        ),
      ),
    );

    final articles = await service.fetchNews();

    expect(articles, hasLength(1));
    expect(articles.single.id, 'news-1');
    expect(articles.single.title, 'Grand Championship 2026');
    expect(articles.single.isFeatured, isTrue);
  });
}
