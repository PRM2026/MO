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
      throw _wrap(error);
    }
  }

  Future<OwnerHorseDetail> getOwnerHorse(String id) async {
    try {
      return await _apiClient.getObject(
        '/owner/horses/$id',
        OwnerHorseDetail.fromJson,
      );
    } on ApiException catch (error) {
      throw _wrap(error);
    }
  }

  Future<OwnerHorseDetail> createHorse(OwnerHorseFormData data) async {
    final name = data.name?.trim();
    if (name == null || name.isEmpty) {
      throw const OwnerApiException('Vui lòng nhập tên ngựa.');
    }

    try {
      return await _apiClient.multipartObject(
        'POST',
        '/owner/horses',
        data.toFields(includeEmptyName: true),
        data.toFilePaths(),
        OwnerHorseDetail.fromJson,
      );
    } on ApiException catch (error) {
      throw _wrap(error);
    }
  }

  Future<OwnerHorseDetail> updateHorse(
    String id,
    OwnerHorseFormData data,
  ) async {
    try {
      return await _apiClient.multipartObject(
        'PUT',
        '/owner/horses/$id',
        data.toFields(includeEmptyName: false),
        data.toFilePaths(),
        OwnerHorseDetail.fromJson,
      );
    } on ApiException catch (error) {
      throw _wrap(error);
    }
  }

  Future<void> deleteHorse(String id) async {
    try {
      await _apiClient.delete('/owner/horses/$id');
    } on ApiException catch (error) {
      throw _wrap(error);
    }
  }

  OwnerApiException _wrap(ApiException error) {
    return OwnerApiException(
      error.message,
      statusCode: error.statusCode,
      code: error.code,
    );
  }
}
