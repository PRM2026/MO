import 'package:flutter/foundation.dart';

import '../models/owner_tournament_detail.dart';
import '../repositories/owner_tournament_repository.dart';

class OwnerTournamentDetailViewModel extends ChangeNotifier {
  OwnerTournamentDetailViewModel({
    required this.tournamentId,
    OwnerTournamentRepository? repository,
  }) : _repository = repository ?? OwnerTournamentRepository();

  final String tournamentId;
  final OwnerTournamentRepository _repository;

  bool isLoading = false;
  String? errorMessage;
  OwnerTournamentDetail? detail;

  Future<void> loadDetail() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      detail = await _repository.fetchTournamentDetail(tournamentId);
    } catch (error) {
      detail = null;
      errorMessage = 'Không thể tải chi tiết giải đấu.';
      if (kDebugMode) {
        debugPrint('OwnerTournamentDetailViewModel: $error');
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => loadDetail();
}
