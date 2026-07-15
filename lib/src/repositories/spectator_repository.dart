import '../models/jockey_race_result_response.dart';
import '../models/owner_tournament_detail.dart';
import '../models/spectator_models.dart';
import '../models/tournament_list_item.dart';
import '../models/user_profile.dart';
import '../services/spectator_api_service.dart';

class SpectatorRepository {
  SpectatorRepository({SpectatorApiService? apiService})
    : _apiService = apiService ?? SpectatorApiService();

  final SpectatorApiService _apiService;

  Future<List<TournamentListItem>> fetchTournaments() {
    return _apiService.getTournaments();
  }

  Future<OwnerTournamentDetail> fetchTournamentDetail(String id) {
    return _apiService.getTournamentDetail(id);
  }

  Future<List<JockeyRaceResultResponse>> fetchRaceResults(String raceId) {
    return _apiService.getRaceResults(raceId);
  }

  Future<List<SpectatorFeaturedHorse>> fetchHorseRankings() {
    return _apiService.getHorseRankings();
  }

  Future<UserProfile> fetchCurrentUser() {
    return _apiService.getCurrentUser();
  }
}
