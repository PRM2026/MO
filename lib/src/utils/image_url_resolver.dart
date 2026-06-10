import 'package:flutter/foundation.dart';

import '../config/api_config.dart';

abstract final class ImageUrlResolver {
  static String resolve(String? raw) {
    if (raw == null) return '';
    var url = raw.trim();
    if (url.isEmpty) return '';

    if (url.startsWith('//')) {
      url = 'https:$url';
    }

    if (url.startsWith('/')) {
      url = '${ApiConfig.serverOrigin}$url';
    } else if (!url.startsWith('http://') && !url.startsWith('https://')) {
      final normalized = url.startsWith('/') ? url.substring(1) : url;
      url = '${ApiConfig.serverOrigin}/$normalized';
    }

    return _fixLocalhostForDevice(url);
  }

  static String _fixLocalhostForDevice(String url) {
    if (kIsWeb) return url;

    final host = ApiConfig.deviceHost;
    return url
        .replaceAll('://localhost:', '://$host:')
        .replaceAll('://127.0.0.1:', '://$host:')
        .replaceAll('//localhost/', '//$host/')
        .replaceAll('//127.0.0.1/', '//$host/');
  }
}
