import '../models/tournament_list_item.dart';
import '../services/tournament_api_service.dart';

class TournamentRepository {
  TournamentRepository({TournamentApiService? apiService})
      : _apiService = apiService ?? TournamentApiService();

  final TournamentApiService _apiService;

  Future<List<TournamentListItem>> fetchTournaments() async {
    try {
      final items = await _apiService.fetchTournaments();
      if (items.isNotEmpty) return items;
      return TournamentListItem.sampleData();
    } on TournamentApiException {
      return TournamentListItem.sampleData();
    }
  }
}
