import 'package:http/http.dart' as http;

import '../models/jockey_invitation_response.dart';
import 'api_client.dart';
import 'api_exception.dart';
import 'auth_storage.dart';

class JockeyInvitationApiException extends ApiException {
  const JockeyInvitationApiException(
    super.message, {
    super.statusCode,
    super.code,
  });
}

class JockeyInvitationService {
  JockeyInvitationService({
    http.Client? client,
    String? baseUrl,
    AuthStorage? storage,
    ApiClient? apiClient,
  }) : _apiClient =
           apiClient ??
           ApiClient(client: client, baseUrl: baseUrl, storage: storage);

  final ApiClient _apiClient;

  Future<List<JockeyInvitationResponse>> getJockeyInvitations() async {
    return _run(
      () => _apiClient.getList(
        '/jockey/invitations',
        JockeyInvitationResponse.fromJson,
      ),
    );
  }

  Future<JockeyInvitationResponse> getJockeyInvitation(int id) async {
    return _run(
      () => _apiClient.getObject(
        '/jockey/invitations/$id',
        JockeyInvitationResponse.fromJson,
      ),
    );
  }

  Future<JockeyInvitationResponse> acceptInvitation(
    int id, {
    String? note,
  }) async {
    return _run(
      () => _apiClient.putObject(
        '/jockey/invitations/$id/accept',
        _decisionBody(note),
        JockeyInvitationResponse.fromJson,
      ),
    );
  }

  Future<JockeyInvitationResponse> rejectInvitation(
    int id, {
    String? note,
  }) async {
    return _run(
      () => _apiClient.putObject(
        '/jockey/invitations/$id/reject',
        _decisionBody(note),
        JockeyInvitationResponse.fromJson,
      ),
    );
  }

  Map<String, dynamic> _decisionBody(String? note) {
    final trimmed = note?.trim();
    if (trimmed == null || trimmed.isEmpty) return {};
    return {'note': trimmed};
  }

  Future<T> _run<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on ApiException catch (error) {
      throw JockeyInvitationApiException(
        error.message,
        statusCode: error.statusCode,
        code: error.code,
      );
    }
  }
}
