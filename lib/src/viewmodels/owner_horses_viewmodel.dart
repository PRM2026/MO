import 'package:flutter/foundation.dart';

import '../models/owner_horse_item.dart';
import '../repositories/auth_repository.dart';
import '../repositories/owner_horse_repository.dart';

class OwnerHorsesViewModel extends ChangeNotifier {
  OwnerHorsesViewModel({
    OwnerHorseRepository? repository,
    AuthRepository? authRepository,
  }) : _repository = repository ?? OwnerHorseRepository(),
       _authRepository = authRepository ?? AuthRepository();

  final OwnerHorseRepository _repository;
  final AuthRepository _authRepository;

  bool isLoading = false;
  String? errorMessage;
  String? profileImageUrl;
  String searchQuery = '';
  OwnerHorseFilter selectedFilter = OwnerHorseFilter.all;
  List<OwnerHorseItem> horses = const [];

  List<OwnerHorseItem> get filteredHorses {
    final query = searchQuery.trim().toLowerCase();

    return horses.where((horse) {
      final matchesQuery =
          query.isEmpty ||
          horse.name.toLowerCase().contains(query) ||
          horse.breed.toLowerCase().contains(query);

      if (!matchesQuery) return false;

      return switch (selectedFilter) {
        OwnerHorseFilter.all => true,
        OwnerHorseFilter.racing => horse.isRacing,
        OwnerHorseFilter.legend => horse.isLegend,
        OwnerHorseFilter.prospect => horse.isProspect,
      };
    }).toList();
  }

  Future<void> loadHorses() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      try {
        final user = await _authRepository.refreshCurrentUser();
        profileImageUrl = user.avatarUrl;
      } catch (_) {}

      final loaded = await _repository.fetchHorses();
      horses = _assignRankLabels(loaded);
    } catch (error) {
      errorMessage = 'Không tải được danh sách ngựa.';
      horses = const [];
      if (kDebugMode) debugPrint('OwnerHorsesViewModel: $error');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshHorses() => loadHorses();

  void updateSearch(String value) {
    searchQuery = value;
    notifyListeners();
  }

  void selectFilter(OwnerHorseFilter filter) {
    if (selectedFilter == filter) return;
    selectedFilter = filter;
    notifyListeners();
  }

  List<OwnerHorseItem> _assignRankLabels(List<OwnerHorseItem> items) {
    if (items.isEmpty) return items;

    final sorted = [...items]
      ..sort((a, b) {
        final winCompare = b.performance.wins.compareTo(a.performance.wins);
        if (winCompare != 0) return winCompare;
        return b.performance.winRate.compareTo(a.performance.winRate);
      });

    final rankById = <String, String>{};
    for (var i = 0; i < sorted.length && i < 3; i++) {
      if (sorted[i].performance.wins > 0) {
        rankById[sorted[i].id] = '#${i + 1} RANK';
      }
    }

    return items
        .map((horse) => horse.copyWith(rankLabel: rankById[horse.id]))
        .toList(growable: false);
  }
}
