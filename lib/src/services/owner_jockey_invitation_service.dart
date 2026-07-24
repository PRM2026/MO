import 'package:http/http.dart' as http;

import '../models/owner_jockey_invitation.dart';
import 'api_client.dart';
import 'api_exception.dart';
import 'auth_storage.dart';

class OwnerJockeyInvitationApiException extends ApiException {
  const OwnerJockeyInvitationApiException(
    super.message, {
    super.statusCode,
    super.code,
  });
}

class OwnerJockeyInvitationService {
  OwnerJockeyInvitationService({
    http.Client? client,
    String? baseUrl,
    AuthStorage? storage,
    ApiClient? apiClient,
  }) : _apiClient =
           apiClient ??
           ApiClient(client: client, baseUrl: baseUrl, storage: storage);

  final ApiClient _apiClient;

  Future<List<OwnerAvailableJockey>> getAvailableJockeys() {
    return _run(
      () => _apiClient.getList('/users/jockeys', OwnerAvailableJockey.fromJson),
    );
  }

  Future<List<OwnerJockeyInvitation>> getInvitations() {
    return _run(
      () => _apiClient.getList(
        '/owner/jockey-invitations',
        OwnerJockeyInvitation.fromJson,
      ),
    );
  }

  Future<OwnerJockeyInvitation> getInvitation(String id) {
    final invitationId = _normalizeId(id);
    return _run(
      () => _apiClient.getObject(
        '/owner/jockey-invitations/$invitationId',
        OwnerJockeyInvitation.fromJson,
      ),
    );
  }

  Future<OwnerJockeyInvitation> createInvitation(
    OwnerJockeyInvitationFormData data,
  ) {
    final validationError = data.validate();
    if (validationError != null) {
      throw OwnerJockeyInvitationApiException(validationError);
    }

    return _run(
      () => _apiClient.postObject(
        '/owner/jockey-invitations',
        data.toJson(),
        OwnerJockeyInvitation.fromJson,
      ),
    );
  }

  Future<List<OwnerAcceptedJockey>> getAcceptedJockeys() {
    return _run(() async {
      final invitations = await _apiClient.getList(
        '/owner/jockey-invitations',
        (json) => json,
      );
      return invitations
          .where(
            (item) =>
                '${item['status'] ?? ''}'.trim().toUpperCase() == 'ACCEPTED',
          )
          .map(OwnerAcceptedJockey.fromJson)
          .toList(growable: false);
    });
  }

  Future<OwnerJockeyInvitation?> cancelInvitation(String id) {
    final invitationId = _normalizeId(id);
    return _run(
      () => _apiClient.putOptionalObject(
        '/owner/jockey-invitations/$invitationId/cancel',
        null,
        OwnerJockeyInvitation.fromJson,
      ),
    );
  }

  String _normalizeId(String id) {
    final trimmed = id.trim();
    if (trimmed.isEmpty) {
      throw const OwnerJockeyInvitationApiException(
        'Không xác định được mã lời mời.',
      );
    }
    return Uri.encodeComponent(trimmed);
  }

  Future<T> _run<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on OwnerJockeyInvitationApiException {
      rethrow;
    } on ApiException catch (error) {
      throw OwnerJockeyInvitationApiException(
        error.message,
        statusCode: error.statusCode,
        code: error.code,
      );
    }
  }
}
