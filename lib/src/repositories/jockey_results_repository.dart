import '../models/jockey_performance_response.dart';
import '../models/jockey_race_response.dart';
import '../models/jockey_race_result_response.dart';
import '../models/jockey_results_data.dart';
import '../models/wallet_transaction_response.dart';
import '../services/jockey_dashboard_service.dart';
import '../services/jockey_race_service.dart';
import '../services/jockey_wallet_service.dart';

class JockeyResultsRepository {
  JockeyResultsRepository({
    JockeyDashboardService? dashboardService,
    JockeyRaceService? raceService,
    JockeyWalletService? walletService,
  }) : _dashboardService = dashboardService ?? JockeyDashboardService(),
       _raceService = raceService ?? JockeyRaceService(),
       _walletService = walletService ?? JockeyWalletService();

  final JockeyDashboardService _dashboardService;
  final JockeyRaceService _raceService;
  final JockeyWalletService _walletService;

  Future<JockeyResultsData> fetchResults() async {
    final values = await Future.wait<Object>([
      _dashboardService.getPerformance(),
      _raceService.getJockeyRaces(),
      _walletService.getJockeyPrizes(),
    ]);
    final performance = values[0] as JockeyPerformanceResponse;
    final races = values[1] as List<JockeyRaceResponse>;
    final prizes = values[2] as List<WalletTransactionResponse>;

    final finalizedRaces = races.where(
      (race) => race.status?.trim().toUpperCase() == 'RESULT_CONFIRMED',
    );
    final resultEntries = await Future.wait(
      finalizedRaces.map((race) async {
        final results = await _raceService.getRaceResults(race.id);
        JockeyRaceResultResponse? jockeyResult;
        for (final result in results) {
          if (result.jockeyId == performance.jockeyId) {
            jockeyResult = result;
            break;
          }
        }
        return MapEntry(race.id, jockeyResult);
      }),
    );

    return JockeyResultsData.fromApi(
      performance: performance,
      races: races,
      jockeyResultsByRaceId: Map.fromEntries(resultEntries),
      prizes: prizes,
    );
  }
}
