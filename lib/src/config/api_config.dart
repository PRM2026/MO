import 'dart:io';

import 'package:flutter/foundation.dart';

/// Cấu hình base URL cho BE Spring Boot (port 8080).
abstract final class ApiConfig {
  /// Đổi IP này nếu chạy trên máy thật (vd: http://192.168.1.10:8080/api/v1).
  static const String physicalDeviceBaseUrl = 'http://192.168.1.100:8080/api/v1';

  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080/api/v1';
    if (Platform.isAndroid) return 'http://10.0.2.2:8080/api/v1';
    if (Platform.isIOS) return 'http://localhost:8080/api/v1';
    return 'http://localhost:8080/api/v1';
  }

  /// Origin BE không có `/api/v1` — dùng ghép URL ảnh tương đối.
  static String get serverOrigin {
    if (kIsWeb) return 'http://localhost:8080';
    if (Platform.isAndroid) return 'http://10.0.2.2:8080';
    if (Platform.isIOS) return 'http://localhost:8080';
    return 'http://localhost:8080';
  }

  /// Host thay thế localhost khi chạy emulator / thiết bị.
  static String get deviceHost {
    if (kIsWeb) return 'localhost';
    if (Platform.isAndroid) return '10.0.2.2';
    return 'localhost';
  }
}
