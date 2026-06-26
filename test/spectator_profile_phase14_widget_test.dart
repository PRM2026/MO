import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horse_racing/src/models/spectator_models.dart';
import 'package:horse_racing/src/repositories/auth_repository.dart';
import 'package:horse_racing/src/viewmodels/spectator_profile_viewmodel.dart';
import 'package:horse_racing/src/views/spectator/spectator_profile_screen.dart';

void main() {
  testWidgets('profile screen renders API profile data', (tester) async {
    final viewModel = _ProfileViewModel(
      profile: const SpectatorProfileData(
        username: 'spectator01',
        email: 'spectator@example.test',
        fullName: 'Spectator One',
        role: 'SPECTATOR',
        avatarUrl: '/uploads/users/7.jpg',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: SpectatorProfileScreen(viewModel: viewModel)),
    );
    await tester.pump();

    expect(find.text('Spectator One'), findsWidgets);
    expect(find.text('spectator@example.test'), findsOneWidget);
    expect(find.text('SPECTATOR'), findsOneWidget);
    expect(find.text('Dang xuat'), findsOneWidget);
  });

  testWidgets('profile screen uses fallback icon when avatar is empty', (
    tester,
  ) async {
    final viewModel = _ProfileViewModel(
      profile: const SpectatorProfileData(
        username: 'spectator01',
        email: '',
        fullName: '',
        role: 'SPECTATOR',
        avatarUrl: '',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: SpectatorProfileScreen(viewModel: viewModel)),
    );
    await tester.pump();

    expect(find.text('spectator01'), findsWidgets);
    expect(find.byIcon(Icons.person_rounded), findsWidgets);
  });

  testWidgets('profile screen shows error and retries', (tester) async {
    final viewModel = _ProfileViewModel(
      profile: const SpectatorProfileData(
        username: 'spectator01',
        email: 'spectator@example.test',
        fullName: 'Spectator One',
        role: 'SPECTATOR',
        avatarUrl: '',
      ),
      failuresBeforeSuccess: 1,
    );

    await tester.pumpWidget(
      MaterialApp(home: SpectatorProfileScreen(viewModel: viewModel)),
    );
    await tester.pump();

    expect(find.textContaining('Temporary failure'), findsOneWidget);
    expect(viewModel.loadCalls, 1);

    await tester.tap(find.text('Thu lai'));
    await tester.pump();

    expect(find.text('Spectator One'), findsWidgets);
    expect(viewModel.loadCalls, 2);
  });

  testWidgets('profile logout clears storage and calls logout callback', (
    tester,
  ) async {
    var loggedOut = false;
    final authRepository = _AuthRepository();
    final viewModel = _ProfileViewModel(
      profile: const SpectatorProfileData(
        username: 'spectator01',
        email: '',
        fullName: 'Spectator One',
        role: 'SPECTATOR',
        avatarUrl: '',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: SpectatorProfileScreen(
          viewModel: viewModel,
          authRepository: authRepository,
          onLoggedOut: () => loggedOut = true,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Dang xuat'));
    await tester.pump();

    expect(authRepository.logoutCalls, 1);
    expect(loggedOut, isTrue);
  });
}

class _ProfileViewModel extends SpectatorProfileViewModel {
  _ProfileViewModel({required this.profile, this.failuresBeforeSuccess = 0});

  final SpectatorProfileData profile;
  int failuresBeforeSuccess;
  int loadCalls = 0;

  @override
  Future<void> load() async {
    loadCalls++;
    if (failuresBeforeSuccess > 0) {
      failuresBeforeSuccess--;
      data = null;
      errorMessage = 'Temporary failure';
      isLoading = false;
      notifyListeners();
      return;
    }

    data = profile;
    errorMessage = null;
    isLoading = false;
    notifyListeners();
  }
}

class _AuthRepository extends AuthRepository {
  int logoutCalls = 0;

  @override
  Future<void> logout() async {
    logoutCalls++;
  }
}
