import 'package:http/http.dart' as http;

import '../models/jockey_race_result_response.dart';
import '../models/owner_tournament_detail.dart';
import '../models/spectator_models.dart';
import '../models/tournament_list_item.dart';
import '../models/user_profile.dart';
import 'api_client.dart';
import 'api_exception.dart';
import 'auth_storage.dart';

class SpectatorApiException extends ApiException {
  const SpectatorApiException(super.message, {super.statusCode, super.code});
}

class SpectatorApiService {
  SpectatorApiService({
    http.Client? client,
    String? baseUrl,
    AuthStorage? storage,
    ApiClient? apiClient,
  }) : _apiClient =
           apiClient ??
           ApiClient(client: client, baseUrl: baseUrl, storage: storage);

  final ApiClient _apiClient;

  Future<List<TournamentListItem>> getTournaments() {
    return _run(
      () => _apiClient.getList(
        '/tournaments',
        TournamentListItem.fromJson,
        authenticated: false,
      ),
    );
  }

  Future<OwnerTournamentDetail> getTournamentDetail(String id) {
    return _run(
      () => _apiClient.getObject(
        '/tournaments/$id',
        OwnerTournamentDetail.fromJson,
        authenticated: false,
      ),
    );
  }

  Future<List<JockeyRaceResultResponse>> getRaceResults(String raceId) {
    return _run(
      () => _apiClient.getList(
        '/races/$raceId/results',
        JockeyRaceResultResponse.fromJson,
        authenticated: false,
      ),
    );
  }

  Future<List<SpectatorFeaturedHorse>> getHorseRankings() {
    return _run(
      () => _apiClient.getList(
        '/horses/rankings',
        SpectatorFeaturedHorse.fromJson,
        authenticated: false,
      ),
    );
  }

  Future<UserProfile> getCurrentUser() {
    return _run(() => _apiClient.getObject('/auth/me', UserProfile.fromJson));
  }

  Future<T> _run<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on ApiException catch (error) {
      throw SpectatorApiException(
        error.message,
        statusCode: error.statusCode,
        code: error.code,
      );
    }
  }
}
