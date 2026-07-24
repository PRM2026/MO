import 'package:http/http.dart' as http;

import '../models/owner_race_registration.dart';
import 'api_client.dart';
import 'api_exception.dart';
import 'auth_storage.dart';

class OwnerRaceRegistrationApiException extends ApiException {
  const OwnerRaceRegistrationApiException(
    super.message, {
    super.statusCode,
    super.code,
  });
}

class OwnerRaceRegistrationService {
  OwnerRaceRegistrationService({
    http.Client? client,
    String? baseUrl,
    AuthStorage? storage,
    ApiClient? apiClient,
  }) : _apiClient =
           apiClient ??
           ApiClient(client: client, baseUrl: baseUrl, storage: storage);

  final ApiClient _apiClient;

  Future<List<OwnerEligibleHorseTeam>> getEligibleTeams(
    String raceId,
  ) => _run(() async {
    final invitations = await _apiClient.getList(
      '/owner/jockey-invitations',
      (json) => json,
    );
    return invitations
        .where(
          (item) =>
              '${item['status'] ?? ''}'.toUpperCase() == 'ACCEPTED' &&
              '${item['raceId'] ?? ''}' == raceId,
        )
        .map(OwnerEligibleHorseTeam.fromJson)
        .where(
          (item) =>
              item.invitationId.isNotEmpty && item.horseId?.isNotEmpty == true,
        )
        .toList(growable: false);
  });

  Future<OwnerRaceRegistration> registerRace(
    String raceId,
    OwnerRaceRegistrationFormData data,
  ) {
    final id = _id(raceId, 'cuộc đua');
    final error = data.validate();
    if (error != null) throw OwnerRaceRegistrationApiException(error);
    return _run(
      () => _apiClient.postObject(
        '/races/$id/registrations',
        data.toJson(),
        OwnerRaceRegistration.fromJson,
      ),
    );
  }

  Future<List<OwnerRaceRegistration>> getRegistrations() => _run(
    () => _apiClient.getList(
      '/owner/race-registrations',
      OwnerRaceRegistration.fromJson,
    ),
  );

  Future<OwnerRaceRegistration> withdrawRegistration(
    String registrationId,
    OwnerRaceRegistrationWithdrawData data,
  ) {
    final id = _id(registrationId, 'đăng ký');
    final error = data.validate();
    if (error != null) throw OwnerRaceRegistrationApiException(error);
    return _run(
      () => _apiClient.putObject(
        '/owner/race-registrations/$id/withdraw',
        data.toJson(),
        OwnerRaceRegistration.fromJson,
      ),
    );
  }

  String _id(String value, String label) {
    final id = value.trim();
    if (id.isEmpty) {
      throw OwnerRaceRegistrationApiException('Không xác định được mã $label.');
    }
    return Uri.encodeComponent(id);
  }

  Future<T> _run<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on OwnerRaceRegistrationApiException {
      rethrow;
    } on ApiException catch (error) {
      throw OwnerRaceRegistrationApiException(
        error.message,
        statusCode: error.statusCode,
        code: error.code,
      );
    }
  }
}
