/// Cấu hình API của hệ thống Horse Racing đã deploy.
abstract final class ApiConfig {
  static const String deployedBaseUrl = 'https://api.horseracing.id.vn/api/v1';
  static const String deployedOrigin = 'https://api.horseracing.id.vn';

  static String get baseUrl => deployedBaseUrl;

  static String get serverOrigin => deployedOrigin;

  static String get deviceHost => 'api.horseracing.id.vn';
}
