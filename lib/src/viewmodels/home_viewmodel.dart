import 'package:flutter/foundation.dart';

import '../models/horse_ranking.dart';
import '../models/news_highlight.dart';
import '../models/stat_metric.dart';
import '../models/tournament_list_item.dart';
import '../repositories/home_repository.dart';
import '../repositories/tournament_repository.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    HomeRepository? homeRepository,
    TournamentRepository? tournamentRepository,
  })  : _homeRepository = homeRepository ?? const HomeRepository(),
        _tournamentRepository = tournamentRepository ?? TournamentRepository();

  final HomeRepository _homeRepository;
  final TournamentRepository _tournamentRepository;

  bool isLoadingTournaments = false;
  List<TournamentListItem> _upcomingTournaments = [];

  String get heroImageUrl => _homeRepository.heroImageUrl;

  List<TournamentListItem> get upcomingTournaments => _upcomingTournaments;

  List<HorseRanking> get rankings => _homeRepository.getHorseRankings();

  List<StatMetric> get stats => _homeRepository.getSystemStats();

  List<NewsHighlight> get news => _homeRepository.getNewsHighlights();

  Future<void> loadUpcomingTournaments() async {
    isLoadingTournaments = true;
    notifyListeners();

    try {
      final items = await _tournamentRepository.fetchTournaments();
      _upcomingTournaments = _selectUpcoming(items);
    } catch (error) {
      if (kDebugMode) {
        debugPrint('HomeViewModel.loadUpcomingTournaments: $error');
      }
      _upcomingTournaments = _selectUpcoming(TournamentListItem.sampleData());
    } finally {
      isLoadingTournaments = false;
      notifyListeners();
    }
  }

  static List<TournamentListItem> _selectUpcoming(
    List<TournamentListItem> items,
  ) {
    const excluded = {'COMPLETED', 'CANCELLED', 'DRAFT'};

    final upcoming = items.where((item) => !excluded.contains(item.status)).toList()
      ..sort((a, b) {
        final aDate = a.startAt ?? DateTime(9999);
        final bDate = b.startAt ?? DateTime(9999);
        return aDate.compareTo(bDate);
      });

    return upcoming.take(10).toList();
  }
}
