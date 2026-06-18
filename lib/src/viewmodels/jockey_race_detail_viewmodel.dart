import 'package:flutter/foundation.dart';

import '../models/jockey_race_response.dart';
import '../repositories/jockey_race_detail_repository.dart';

class JockeyRaceDetailViewModel extends ChangeNotifier {
  JockeyRaceDetailViewModel({
    required this.raceId,
    JockeyRaceDetailRepository? repository,
  }) : _repository = repository ?? JockeyRaceDetailRepository();

  final String raceId;
  final JockeyRaceDetailRepository _repository;

  bool isLoading = false;
  String? errorMessage;
  JockeyRaceResponse? race;

  Future<void> loadRace() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      race = await _repository.fetchRace(raceId);
    } on JockeyRaceNotFoundException {
      race = null;
      errorMessage = 'Không tìm thấy cuộc đua này trong lịch của bạn.';
    } catch (error) {
      if (kDebugMode) debugPrint('JockeyRaceDetailViewModel: $error');
      race = null;
      errorMessage = 'Không thể tải chi tiết cuộc đua.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
