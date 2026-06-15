import 'package:flutter/foundation.dart';

import '../models/tournament_list_item.dart';
import '../repositories/auth_repository.dart';
import '../repositories/owner_tournament_repository.dart';

enum OwnerTournamentFilter { all, upcoming, ongoing, completed }

extension OwnerTournamentFilterX on OwnerTournamentFilter {
  String get label {
    return switch (this) {
      OwnerTournamentFilter.all => 'Tất cả',
      OwnerTournamentFilter.upcoming => 'Sắp diễn ra',
      OwnerTournamentFilter.ongoing => 'Đang diễn ra',
      OwnerTournamentFilter.completed => 'Đã kết thúc',
    };
  }
}

class OwnerTournamentsViewModel extends ChangeNotifier {
  OwnerTournamentsViewModel({
    OwnerTournamentRepository? repository,
    AuthRepository? authRepository,
  }) : _repository = repository ?? OwnerTournamentRepository(),
       _authRepository = authRepository ?? AuthRepository();

  final OwnerTournamentRepository _repository;
  final AuthRepository _authRepository;

  bool isLoading = false;
  String? errorMessage;
  String? profileImageUrl;
  OwnerTournamentFilter selectedFilter = OwnerTournamentFilter.all;
  List<TournamentListItem> _allTournaments = const [];

  List<TournamentListItem> get tournaments {
    return _allTournaments.where(_matchesFilter).toList();
  }

  bool _matchesFilter(TournamentListItem item) {
    return switch (selectedFilter) {
      OwnerTournamentFilter.all => true,
      OwnerTournamentFilter.upcoming => item.isOwnerUpcoming,
      OwnerTournamentFilter.ongoing => item.isOwnerOngoing,
      OwnerTournamentFilter.completed => item.isOwnerCompleted,
    };
  }

  Future<void> loadTournaments() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      try {
        final user = await _authRepository.refreshCurrentUser();
        profileImageUrl = user.avatarUrl;
      } catch (_) {}

      _allTournaments = await _repository.fetchTournaments();
    } catch (error) {
      errorMessage = 'Không thể tải giải đấu.';
      _allTournaments = const [];
      if (kDebugMode) debugPrint('OwnerTournamentsViewModel: $error');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshTournaments() => loadTournaments();

  void selectFilter(OwnerTournamentFilter filter) {
    if (selectedFilter == filter) return;
    selectedFilter = filter;
    notifyListeners();
  }
}
