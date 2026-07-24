import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:horse_racing/src/services/auth_storage.dart';
import 'package:horse_racing/src/services/betting_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'auth_token': 'jwt-token'});
  });

  test('loads typed bettable markets with authenticated request', () async {
    late http.Request captured;
    final preferences = await SharedPreferences.getInstance();
    final service = BettingService(
      baseUrl: 'https://api.example.test',
      storage: AuthStorage(preferences: preferences),
      client: MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode({
            'success': true,
            'message': 'ok',
            'data': [
              {
                'id': 4,
                'raceId': 8,
                'raceName': 'Sprint Final',
                'tournamentId': 2,
                'tournamentName': 'Summer Cup',
                'status': 'OPEN',
                'minStake': 10000,
                'maxStake': 500000,
                'options': [
                  {
                    'participantId': 11,
                    'horseId': 7,
                    'horseName': 'Night Wind',
                    'gateNumber': 3,
                  },
                ],
              },
            ],
          }),
          200,
        );
      }),
    );

    final markets = await service.getBettableMarkets();

    expect(captured.url.path, '/users/me/bettable-races');
    expect(captured.headers['authorization'], 'Bearer jwt-token');
    expect(markets.single.raceName, 'Sprint Final');
    expect(markets.single.options.single.horseName, 'Night Wind');
  });

  test('place bet posts participant and stake payload', () async {
    late http.Request captured;
    final preferences = await SharedPreferences.getInstance();
    final service = BettingService(
      baseUrl: 'https://api.example.test',
      storage: AuthStorage(preferences: preferences),
      client: MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode({
            'success': true,
            'message': 'ok',
            'data': {
              'id': 99,
              'marketId': 4,
              'raceId': 8,
              'raceName': 'Sprint Final',
              'participantId': 11,
              'horseId': 7,
              'horseName': 'Night Wind',
              'stakeAmount': 50000,
              'potentialPayoutAmount': 95000,
              'status': 'PENDING',
            },
          }),
          200,
        );
      }),
    );

    final bet = await service.placeBet(
      raceId: '8',
      participantId: '11',
      stakeAmount: 50000,
    );

    expect(captured.url.path, '/races/8/bets');
    expect(jsonDecode(captured.body), {
      'participantId': '11',
      'stakeAmount': 50000,
    });
    expect(bet.id, '99');
    expect(bet.status, 'PENDING');
  });
}
