import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horse_racing/src/models/jockey_invitation_data.dart';
import 'package:horse_racing/src/repositories/jockey_invitation_repository.dart';
import 'package:horse_racing/src/services/jockey_invitation_service.dart';
import 'package:horse_racing/src/viewmodels/jockey_invitation_viewmodel.dart';
import 'package:horse_racing/src/views/jockey/jockey_invitations_screen.dart';

void main() {
  testWidgets('renders invitation list and filters by status', (tester) async {
    final viewModel = JockeyInvitationsViewModel(
      repository: _FakeRepository(
        invitations: [
          _item(id: '1', horse: 'Night Wind', status: 'PENDING'),
          _item(id: '2', horse: 'Morning Star', status: 'ACCEPTED'),
        ],
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: JockeyInvitationsScreen(viewModel: viewModel)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Lời mời thi đấu'), findsOneWidget);
    expect(find.text('Night Wind'), findsOneWidget);
    expect(find.text('Morning Star'), findsOneWidget);
    expect(find.text('Chờ phản hồi'), findsWidgets);

    await tester.tap(find.text('Đã nhận').first);
    await tester.pump();

    expect(find.text('Night Wind'), findsNothing);
    expect(find.text('Morning Star'), findsOneWidget);
  });

  testWidgets('shows filter-specific empty state', (tester) async {
    final viewModel = JockeyInvitationsViewModel(
      repository: _FakeRepository(
        invitations: [_item(id: '1', horse: 'Night Wind', status: 'PENDING')],
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: JockeyInvitationsScreen(viewModel: viewModel)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Từ chối'));
    await tester.pump();

    expect(find.text('Không có lời mời ở trạng thái từ chối.'), findsOneWidget);
  });

  testWidgets('shows API error with retry action', (tester) async {
    final viewModel = JockeyInvitationsViewModel(
      repository: _FakeRepository(
        error: const JockeyInvitationApiException('Không thể tải lời mời'),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: JockeyInvitationsScreen(viewModel: viewModel)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Không thể tải lời mời'), findsOneWidget);
    expect(find.text('Thu lai'), findsOneWidget);
  });

  testWidgets('tapping invitation opens the detail route', (tester) async {
    final viewModel = JockeyInvitationsViewModel(
      repository: _FakeRepository(
        invitations: [_item(id: '7', horse: 'Night Wind')],
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: JockeyInvitationsScreen(
          viewModel: viewModel,
          detailBuilder: (_, id) =>
              Scaffold(body: Center(child: Text('Detail $id'))),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Night Wind'));
    await tester.pumpAndSettle();

    expect(find.text('Detail 7'), findsOneWidget);
  });

  testWidgets('detail renders API data without Phase 8 actions', (
    tester,
  ) async {
    final detail = _detail();
    final viewModel = JockeyInvitationDetailViewModel(
      invitationId: '7',
      repository: _FakeRepository(detail: detail),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: JockeyInvitationDetailScreen(
          invitationId: '7',
          viewModel: viewModel,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('CHI TIẾT LỜI MỜI'), findsOneWidget);
    expect(find.text('Night Wind'), findsOneWidget);
    expect(find.text('stable_owner'), findsOneWidget);
    expect(find.text('Autumn Sprint'), findsOneWidget);
    expect(find.text('National Cup'), findsOneWidget);
    expect(find.text('500.000 đ'), findsOneWidget);
    expect(find.text('Mời bạn tham gia.'), findsOneWidget);
    expect(find.textContaining('Chấp nhận'), findsNothing);
    expect(find.textContaining('Từ chối lời mời'), findsNothing);
  });
}

JockeyInvitationListItem _item({
  required String id,
  required String horse,
  String status = 'PENDING',
}) {
  final label = switch (status) {
    'ACCEPTED' => 'Đã nhận',
    'REJECTED' => 'Từ chối',
    'CANCELLED' => 'Đã hủy',
    _ => 'Chờ phản hồi',
  };
  return JockeyInvitationListItem(
    id: id,
    horseName: horse,
    ownerName: 'stable_owner',
    raceName: 'Autumn Sprint',
    tournamentName: 'National Cup',
    remunerationLabel: '500.000 đ',
    createdAtLabel: '18/06/2026 08:00',
    statusCode: status,
    statusLabel: label,
  );
}

JockeyInvitationDetail _detail() {
  return const JockeyInvitationDetail(
    id: '7',
    ownerName: 'stable_owner',
    ownerReference: 'Chủ ngựa #3',
    jockeyReference: 'minh_jockey',
    horseName: 'Night Wind',
    horseReference: 'Ngựa #21',
    raceName: 'Autumn Sprint',
    raceReference: 'Cuộc đua #31',
    tournamentName: 'National Cup',
    tournamentReference: 'Giải đấu #41',
    remunerationLabel: '500.000 đ',
    message: 'Mời bạn tham gia.',
    responseNote: '',
    statusCode: 'PENDING',
    statusLabel: 'Chờ phản hồi',
    createdAtLabel: '18/06/2026 08:00',
    updatedAtLabel: '18/06/2026 09:00',
    respondedAtLabel: '',
    cancelledAtLabel: '',
  );
}

class _FakeRepository extends JockeyInvitationRepository {
  _FakeRepository({this.invitations = const [], this.detail, this.error});

  final List<JockeyInvitationListItem> invitations;
  final JockeyInvitationDetail? detail;
  final Object? error;

  @override
  Future<List<JockeyInvitationListItem>> fetchInvitations() async {
    if (error != null) throw error!;
    return invitations;
  }

  @override
  Future<JockeyInvitationDetail> fetchInvitationDetail(String id) async {
    if (error != null) throw error!;
    return detail!;
  }
}
