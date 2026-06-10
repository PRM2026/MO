import '../models/race_result_confirmation.dart';

class RefereeHistoryRepository {
  const RefereeHistoryRepository();

  Future<RaceResultConfirmationData> fetchResultConfirmation() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return RaceResultConfirmationData.sample();
  }
}
