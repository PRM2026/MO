import 'package:http/http.dart' as http;

import '../models/owner_horse_item.dart';
import 'api_client.dart';
import 'api_exception.dart';
import 'auth_storage.dart';

class OwnerApiException extends ApiException {
  const OwnerApiException(super.message, {super.statusCode, super.code});
}

class OwnerHorseService {
  OwnerHorseService({
    http.Client? client,
    String? baseUrl,
    AuthStorage? storage,
    ApiClient? apiClient,
  }) : _apiClient =
           apiClient ??
           ApiClient(client: client, baseUrl: baseUrl, storage: storage);

  final ApiClient _apiClient;

  Future<List<OwnerHorseItem>> getOwnerHorses() async {
    try {
      return await _apiClient.getList('/owner/horses', OwnerHorseItem.fromJson);
    } on ApiException catch (error) {
      throw OwnerApiException(
        error.message,
        statusCode: error.statusCode,
        code: error.code,
      );
    }
  }
}
