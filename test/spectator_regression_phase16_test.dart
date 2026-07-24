import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:horse_racing/src/utils/role_utils.dart';
import 'package:horse_racing/src/widgets/spectator/spectator_bottom_nav.dart';

void main() {
  group('Spectator phase 16 regression', () {
    test(
      'role routing keeps spectator dedicated portal without changing peers',
      () {
        expect(hasDedicatedPortal('SPECTATOR'), isTrue);
        expect(hasDedicatedPortal('OWNER'), isTrue);
        expect(hasDedicatedPortal('HORSE_OWNER'), isTrue);
        expect(hasDedicatedPortal('JOCKEY'), isTrue);
        expect(hasDedicatedPortal('REFEREE'), isTrue);
        expect(hasDedicatedPortal('ADMIN'), isTrue);
        expect(hasDedicatedPortal('USER'), isFalse);
        expect(normalizePortalRole('HORSE_OWNER'), 'OWNER');
        expect(
          resolveEffectiveAppRole(role: 'spectator', roleApprovalStatus: null),
          'SPECTATOR',
        );
      },
    );

    test('bottom nav covers betting, profile and expanded actions', () {
      expect(SpectatorTab.values, [
        SpectatorTab.home,
        SpectatorTab.races,
        SpectatorTab.betting,
        SpectatorTab.results,
        SpectatorTab.profile,
        SpectatorTab.more,
      ]);
    });

    test('spectator routes are declared separately', () {
      final routes = File('lib/src/routes/app_routes.dart').readAsStringSync();

      expect(routes, contains('spectatorRaceDetail'));
      expect(routes, contains('spectatorRaceResults'));
      expect(routes, contains('spectatorTournamentDetail'));
      expect(routes, contains('spectatorHorseRanking'));
      expect(routes, contains('SpectatorShell'));
    });

    test('production spectator code does not use mocks or owner endpoints', () {
      final files = _spectatorProductionFiles();
      expect(files, isNotEmpty);

      const forbidden = [
        'spectator_home_mock.dart',
        'spectator_races_mock.dart',
        'spectator_results_mock.dart',
        'SpectatorHomeMock',
        'SpectatorRacesMock',
        'SpectatorResultsMock',
        'TournamentListItem.sampleData(',
        '/owner/',
        '/owner/dashboard',
        '/owner/horses',
        '/owner/races',
        '/owner/prizes',
        'owner/horses',
      ];

      for (final file in files) {
        final content = file.readAsStringSync();
        for (final pattern in forbidden) {
          expect(
            content.contains(pattern),
            isFalse,
            reason:
                '${file.path} contains forbidden spectator pattern $pattern',
          );
        }
      }
    });

    test('public spectator API methods stay unauthenticated where expected', () {
      final service = File(
        'lib/src/services/spectator_api_service.dart',
      ).readAsStringSync();

      expect(service, contains("'/tournaments'"));
      expect(service, contains("'/tournaments/\$id'"));
      expect(service, contains("'/races/\$raceId/results'"));
      expect(service, contains("'/horses/rankings'"));
      expect(
        RegExp(
          r"getList\([\s\S]*'/tournaments'[\s\S]*authenticated: false",
        ).hasMatch(service),
        isTrue,
      );
      expect(
        RegExp(
          r"getObject\([\s\S]*'/tournaments/\$id'[\s\S]*authenticated: false",
        ).hasMatch(service),
        isTrue,
      );
      expect(
        RegExp(
          r"getList\([\s\S]*'/races/\$raceId/results'[\s\S]*authenticated: false",
        ).hasMatch(service),
        isTrue,
      );
      expect(
        RegExp(
          r"getList\([\s\S]*'/horses/rankings'[\s\S]*authenticated: false",
        ).hasMatch(service),
        isTrue,
      );
      expect(service, contains("'/auth/me'"));
    });
  });
}

List<File> _spectatorProductionFiles() {
  final roots = [
    Directory('lib/src/views/spectator'),
    Directory('lib/src/widgets/spectator'),
    Directory('lib/src/viewmodels'),
    Directory('lib/src/services'),
    Directory('lib/src/repositories'),
  ];

  return roots
      .where((root) => root.existsSync())
      .expand(
        (root) => root
            .listSync(recursive: true)
            .whereType<File>()
            .where((file) => file.path.endsWith('.dart')),
      )
      .where((file) {
        final path = file.path.replaceAll('\\', '/');
        if (path.contains('/views/spectator/')) return true;
        if (path.contains('/widgets/spectator/')) return true;
        if (path.contains('/viewmodels/spectator_')) return true;
        if (path.endsWith('/spectator_api_service.dart')) return true;
        if (path.endsWith('/spectator_repository.dart')) return true;
        return false;
      })
      .toList(growable: false);
}
