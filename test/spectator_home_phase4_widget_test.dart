import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horse_racing/src/models/spectator_models.dart';
import 'package:horse_racing/src/viewmodels/spectator_home_viewmodel.dart';
import 'package:horse_racing/src/views/spectator/spectator_home_screen.dart';

void main() {
  testWidgets('home app bar renders API profile summary', (tester) async {
    final viewModel = _HomeViewModel(
      data: const SpectatorHomeData(
        profile: SpectatorProfileData(
          username: 'spectator01',
          email: 'spectator@example.test',
          fullName: 'Spectator One',
          role: 'SPECTATOR',
          avatarUrl: '/uploads/users/7.jpg',
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: SpectatorHomeScreen(viewModel: viewModel)),
    );
    await tester.pump();

    expect(find.textContaining('Spectator One'), findsOneWidget);
    expect(find.textContaining('Khan gia'), findsNothing);
  });

  testWidgets('home app bar uses generic spectator when profile is missing', (
    tester,
  ) async {
    final viewModel = _HomeViewModel(data: const SpectatorHomeData());

    await tester.pumpWidget(
      MaterialApp(home: SpectatorHomeScreen(viewModel: viewModel)),
    );
    await tester.pump();

    expect(find.textContaining('Khan gia'), findsOneWidget);
    expect(find.text('Chua co giai dau noi bat.'), findsOneWidget);
    expect(find.text('Chua co cuoc dua sap toi.'), findsOneWidget);
    expect(find.text('Chua co bang xep hang ngua.'), findsOneWidget);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pump();
    expect(find.text('Chua co ket qua gan day.'), findsOneWidget);
  });

  testWidgets('home upcoming race tap opens races flow', (tester) async {
    var openedRaces = false;
    final viewModel = _HomeViewModel(
      data: SpectatorHomeData(
        upcomingRaces: [
          SpectatorRaceItem.fromJson(const {
            'id': 5,
            'name': 'Qualifier',
            'distance': '1200m',
            'scheduledStartAt': '2026-07-15T09:00:00',
            'status': 'SCHEDULED',
          }),
        ],
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: SpectatorHomeScreen(
          viewModel: viewModel,
          onRacesTap: () => openedRaces = true,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Qualifier'));
    await tester.pump();

    expect(openedRaces, isTrue);
  });
}

class _HomeViewModel extends SpectatorHomeViewModel {
  _HomeViewModel({required SpectatorHomeData data}) : _nextData = data;

  final SpectatorHomeData _nextData;

  @override
  Future<void> load() async {
    data = _nextData;
    isLoading = false;
    errorMessage = null;
    profileErrorMessage = null;
    notifyListeners();
  }
}
