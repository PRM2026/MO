import '../models/owner_tournament_detail.dart';
import '../models/tournament_list_item.dart';
import '../services/tournament_api_service.dart';

class OwnerTournamentRepository {
  OwnerTournamentRepository({TournamentApiService? apiService})
    : _apiService = apiService ?? TournamentApiService();

  final TournamentApiService _apiService;

  Future<List<TournamentListItem>> fetchTournaments() {
    return _apiService.fetchTournaments();
  }

  Future<OwnerTournamentDetail> fetchTournamentDetail(String id) {
    return _apiService.fetchTournamentDetail(id);
  }
}
