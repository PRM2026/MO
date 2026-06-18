import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horse_racing/src/models/jockey_profile_response.dart';
import 'package:horse_racing/src/repositories/jockey_profile_repository.dart';
import 'package:horse_racing/src/viewmodels/jockey_profile_edit_viewmodel.dart';
import 'package:horse_racing/src/viewmodels/jockey_profile_viewmodel.dart';
import 'package:horse_racing/src/views/jockey/jockey_profile_edit_screen.dart';
import 'package:horse_racing/src/views/jockey/jockey_profile_screen.dart';

void main() {
  testWidgets('shows review reason for rejected profile', (tester) async {
    final viewModel = JockeyProfileViewModel(
      repository: _FakeProfileRepository(
        profile: _profile(
          status: 'REJECTED',
          reviewReason: 'License document is invalid',
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: JockeyProfileScreen(viewModel: viewModel)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Minh Nguyen'), findsOneWidget);
    expect(find.text('License document is invalid'), findsOneWidget);
  });

  testWidgets('shows empty race history state', (tester) async {
    final viewModel = JockeyProfileViewModel(
      repository: _FakeProfileRepository(profile: _profile()),
    );

    await tester.pumpWidget(
      MaterialApp(home: JockeyProfileScreen(viewModel: viewModel)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Chua co lich su dua.'), findsOneWidget);
    expect(find.text('Bao mat & Mat khau'), findsOneWidget);
    expect(find.text('Dang xuat'), findsOneWidget);
  });

  testWidgets('edit form prefills profile and disables unchanged submit', (
    tester,
  ) async {
    final profile = _profile();
    final viewModel = JockeyProfileEditViewModel(
      initialProfile: profile,
      repository: _FakeProfileRepository(profile: profile),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: JockeyProfileEditScreen(profile: profile, viewModel: viewModel),
      ),
    );

    final fields = tester
        .widgetList<TextField>(find.byType(TextField))
        .toList();
    expect(fields[0].controller!.text, 'JCK-2026-001');
    expect(fields[1].controller!.text, '7');
    expect(fields[2].controller!.text, '168');
    expect(fields[3].controller!.text, '54');
    expect(fields[4].controller!.text, 'Professional jockey');
    expect(fields[5].controller!.text, 'National Cup 2025');
    expect(fields[6].controller!.text, 'Sprint');

    FilledButton submitButton() => tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Luu thay doi'),
    );

    expect(submitButton().onPressed, isNull);
    await tester.enterText(find.byType(TextField).at(4), 'Updated bio');
    await tester.pump();
    expect(submitButton().onPressed, isNotNull);
  });

  testWidgets('suspended profile does not show edit action', (tester) async {
    final viewModel = JockeyProfileViewModel(
      repository: _FakeProfileRepository(
        profile: _profile(status: 'SUSPENDED'),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: JockeyProfileScreen(viewModel: viewModel)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Chinh sua ho so'), findsNothing);
  });
}

JockeyProfileResponse _profile({
  String status = 'APPROVED',
  String? reviewReason,
}) {
  return JockeyProfileResponse(
    id: 11,
    userId: 5,
    username: 'minh_jockey',
    fullName: 'Minh Nguyen',
    licenseNumber: 'JCK-2026-001',
    experienceYears: 7,
    heightCm: 168,
    weightKg: 54,
    bio: 'Professional jockey',
    awards: 'National Cup 2025',
    achievements: 'Top jockey',
    specialties: 'Sprint',
    status: status,
    reviewReason: reviewReason,
    performance: const JockeyProfilePerformance(
      totalRaces: 12,
      wins: 4,
      winRate: 33.33,
      rankCounts: {'1': 4, '2': 2, '3': 1},
    ),
    raceHistory: const [],
  );
}

class _FakeProfileRepository extends JockeyProfileRepository {
  _FakeProfileRepository({required this.profile});

  final JockeyProfileResponse profile;

  @override
  Future<JockeyProfileResponse> fetchProfile() async => profile;

  @override
  Future<JockeyProfileResponse> updateProfile({
    required Map<String, String> fields,
    Map<String, String> filePaths = const {},
  }) async {
    return profile;
  }
}
