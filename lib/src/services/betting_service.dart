import 'package:http/http.dart' as http;

import '../models/betting_models.dart';
import 'api_client.dart';
import 'auth_storage.dart';

class BettingService {
  BettingService({
    http.Client? client,
    String? baseUrl,
    AuthStorage? storage,
    ApiClient? apiClient,
  }) : _apiClient =
           apiClient ??
           ApiClient(client: client, baseUrl: baseUrl, storage: storage);

  final ApiClient _apiClient;

  Future<List<BetMarket>> getBettableMarkets() {
    return _apiClient.getList('/users/me/bettable-races', BetMarket.fromJson);
  }

  Future<BetMarket> getMarket(String raceId) {
    return _apiClient.getObject(
      '/races/$raceId/bet-market',
      BetMarket.fromJson,
    );
  }

  Future<BetRecord> placeBet({
    required String raceId,
    required String participantId,
    required num stakeAmount,
  }) {
    return _apiClient.postObject('/races/$raceId/bets', {
      'participantId': participantId,
      'stakeAmount': stakeAmount,
    }, BetRecord.fromJson);
  }

  Future<List<BetRecord>> getMyBets() {
    return _apiClient.getList('/users/me/bets', BetRecord.fromJson);
  }

  Future<BetRecord> getMyBet(String id) {
    return _apiClient.getObject('/bets/$id', BetRecord.fromJson);
  }
}
