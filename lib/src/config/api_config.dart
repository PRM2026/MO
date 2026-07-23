/// Cấu hình API của hệ thống Horse Racing đã deploy.
abstract final class ApiConfig {
  static const String deployedBaseUrl =
      'https://be-production-dcb3.up.railway.app/api/v1';
  static const String deployedOrigin =
      'https://be-production-dcb3.up.railway.app';

  static String get baseUrl => deployedBaseUrl;

  static String get serverOrigin => deployedOrigin;

  static String get deviceHost => 'be-production-dcb3.up.railway.app';
}
