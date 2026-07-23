import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:horse_racing/src/services/auth_storage.dart';
import 'package:horse_racing/src/services/referee_dashboard_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'referee check-in sends status to assigned participant endpoint',
    () async {
      SharedPreferences.setMockInitialValues({'auth_token': 'jwt'});
      final preferences = await SharedPreferences.getInstance();
      late http.Request captured;
      final service = RefereeDashboardService(
        baseUrl: 'https://api.example.test',
        storage: AuthStorage(preferences: preferences),
        client: MockClient((request) async {
          captured = request;
          return http.Response(
            jsonEncode({
              'success': true,
              'message': 'ok',
              'data': {
                'id': 7,
                'raceId': 3,
                'horseId': 9,
                'status': 'CHECKED_IN',
              },
            }),
            200,
          );
        }),
      );

      final participant = await service.checkInParticipant(
        raceId: '3',
        participantId: '7',
        status: 'CHECKED_IN',
      );

      expect(captured.url.path, '/referee/races/3/participants/7/check-in');
      expect(jsonDecode(captured.body), {'status': 'CHECKED_IN'});
      expect(participant.status, 'CHECKED_IN');
    },
  );
}
