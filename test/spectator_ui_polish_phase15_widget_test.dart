import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horse_racing/src/models/spectator_models.dart';
import 'package:horse_racing/src/viewmodels/spectator_home_viewmodel.dart';
import 'package:horse_racing/src/views/spectator/spectator_home_screen.dart';
import 'package:horse_racing/src/widgets/spectator/spectator_bottom_nav.dart';

void main() {
  testWidgets('spectator bottom nav exposes betting and full portal menu', (
    tester,
  ) async {
    SpectatorTab? selected;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: SpectatorBottomNav(
            currentTab: SpectatorTab.home,
            onTabSelected: (tab) => selected = tab,
          ),
        ),
      ),
    );

    expect(find.text('Trang chu'), findsOneWidget);
    expect(find.text('Cuoc dua'), findsOneWidget);
    expect(find.text('Đặt cược'), findsOneWidget);
    expect(find.text('Ket qua'), findsOneWidget);
    expect(find.text('Thêm'), findsOneWidget);

    await tester.tap(find.text('Ket qua'));
    await tester.pump();

    expect(selected, SpectatorTab.results);
  });

  testWidgets('home polish renders long API text and empty images', (
    tester,
  ) async {
    final longText =
        'Ten giai dau rat dai tu backend de kiem tra wrap overflow tren man hinh spectator';
    final viewModel = _HomeViewModel(
      data: SpectatorHomeData(
        featuredEvent: SpectatorFeaturedEvent(
          id: '12',
          title: longText,
          dateLabel: '15/07/2026',
          location:
              'Dia diem rat dai voi nhieu thong tin tinh thanh va dia chi san dau',
          imageUrl: '',
          status: 'OPEN_REGISTRATION',
        ),
        upcomingRaces: [
          SpectatorRaceItem.fromJson({
            'id': 5,
            'tournamentId': 12,
            'tournamentName': longText,
            'name': longText,
            'distance': '1200m',
            'venueName':
                'San dau co ten rat dai de kiem tra ellipsis trong card',
            'scheduledStartAt': '2026-07-15T09:00:00',
            'participantCount': 4,
            'maxParticipants': 12,
            'status': 'SCHEDULED',
          }),
        ],
        featuredHorses: [
          SpectatorFeaturedHorse(
            id: '8',
            name: longText,
            rider: 'jockey-name-that-is-long-from-api',
            rank: 1,
            imageUrl: '',
            winRateLabel: '80%',
          ),
        ],
        recentResults: [
          SpectatorRecentResult(
            raceId: '5',
            horseName: longText,
            time: '1:08.123',
            eventName: longText,
          ),
        ],
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: SpectatorHomeScreen(viewModel: viewModel)),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.textContaining('Ten giai dau'), findsWidgets);
    expect(find.text('Xem chi tiet'), findsOneWidget);
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
