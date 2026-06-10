import 'package:flutter/foundation.dart';

import '../models/tournament_list_item.dart';
import '../repositories/tournament_repository.dart';

class TournamentsViewModel extends ChangeNotifier {
  TournamentsViewModel({TournamentRepository? repository})
      : _repository = repository ?? TournamentRepository();

  final TournamentRepository _repository;

  bool isLoading = false;
  String? errorMessage;
  String searchQuery = '';
  List<TournamentListItem> _allTournaments = [];

  List<TournamentListItem> get tournaments {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) return _allTournaments;

    return _allTournaments
        .where(
          (item) =>
              item.title.toLowerCase().contains(query) ||
              item.location.toLowerCase().contains(query),
        )
        .toList();
  }

  Future<void> loadTournaments() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      _allTournaments = await _repository.fetchTournaments();
    } catch (error) {
      errorMessage = 'Không thể tải giải đấu.';
      if (kDebugMode) errorMessage = '$errorMessage ($error)';
      _allTournaments = TournamentListItem.sampleData();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshTournaments() => loadTournaments();

  void updateSearch(String value) {
    searchQuery = value;
    notifyListeners();
  }
}
