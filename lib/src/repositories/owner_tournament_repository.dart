import '../models/tournament_list_item.dart';
import '../services/tournament_api_service.dart';

class OwnerTournamentRepository {
  OwnerTournamentRepository({TournamentApiService? apiService})
    : _apiService = apiService ?? TournamentApiService();

  final TournamentApiService _apiService;

  Future<List<TournamentListItem>> fetchTournaments() {
    return _apiService.fetchTournaments();
  }
}
