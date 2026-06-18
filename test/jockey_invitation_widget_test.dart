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

  testWidgets('list reloads when detail returns action result true', (
    tester,
  ) async {
    final repository = _FakeRepository(
      invitations: [_item(id: '7', horse: 'Night Wind')],
    );
    final viewModel = JockeyInvitationsViewModel(repository: repository);

    await tester.pumpWidget(
      MaterialApp(
        home: JockeyInvitationsScreen(
          viewModel: viewModel,
          detailBuilder: (detailContext, id) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () => Navigator.of(detailContext).pop(true),
                child: const Text('Complete action'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(repository.listFetches, 1);

    await tester.tap(find.text('Night Wind'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Complete action'));
    await tester.pumpAndSettle();

    expect(repository.listFetches, 2);
  });

  testWidgets('pending detail shows accept and reject actions', (tester) async {
    final viewModel = JockeyInvitationDetailViewModel(
      invitationId: '7',
      repository: _FakeRepository(detail: _detail()),
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

    expect(find.text('Chấp nhận'), findsOneWidget);
    expect(find.text('Từ chối'), findsOneWidget);
  });

  testWidgets('non-pending detail hides action bar', (tester) async {
    final viewModel = JockeyInvitationDetailViewModel(
      invitationId: '7',
      repository: _FakeRepository(
        detail: _detail(status: 'ACCEPTED', label: 'Đã nhận'),
      ),
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

    expect(find.text('Chấp nhận'), findsNothing);
    expect(find.text('Từ chối'), findsNothing);
  });

  testWidgets('accept opens note dialog and reloads detail on success', (
    tester,
  ) async {
    final pending = _detail();
    final accepted = _detail(
      status: 'ACCEPTED',
      label: 'Đã nhận',
      responseNote: 'Ready',
    );
    final repository = _FakeRepository(detailQueue: [pending, accepted]);
    final viewModel = JockeyInvitationDetailViewModel(
      invitationId: '7',
      repository: repository,
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

    await tester.tap(find.text('Chấp nhận'));
    await tester.pumpAndSettle();
    expect(find.text('Chấp nhận lời mời'), findsOneWidget);

    await tester.enterText(find.byType(TextField), ' Ready ');
    await tester.tap(find.text('Chấp nhận').last);
    await tester.pumpAndSettle();

    expect(repository.acceptCalls, 1);
    expect(repository.lastNote, 'Ready');
    expect(viewModel.actionCompleted, isTrue);
    expect(find.text('Đã nhận'), findsWidgets);
    expect(find.text('Chấp nhận'), findsNothing);
  });

  testWidgets('reject action error shows backend message and keeps detail', (
    tester,
  ) async {
    final repository = _FakeRepository(
      detail: _detail(),
      actionError: const JockeyInvitationApiException(
        'Invitation is no longer pending',
      ),
    );
    final viewModel = JockeyInvitationDetailViewModel(
      invitationId: '7',
      repository: repository,
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

    await tester.tap(find.text('Từ chối'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Từ chối').last);
    await tester.pumpAndSettle();

    expect(repository.rejectCalls, 1);
    expect(viewModel.actionCompleted, isFalse);
    expect(viewModel.actionError, 'Invitation is no longer pending');
    expect(find.text('Night Wind'), findsOneWidget);
    expect(find.text('Từ chối'), findsOneWidget);
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

JockeyInvitationDetail _detail({
  String status = 'PENDING',
  String label = 'Chờ phản hồi',
  String responseNote = '',
}) {
  return JockeyInvitationDetail(
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
    responseNote: responseNote,
    statusCode: status,
    statusLabel: label,
    createdAtLabel: '18/06/2026 08:00',
    updatedAtLabel: '18/06/2026 09:00',
    respondedAtLabel: '',
    cancelledAtLabel: '',
  );
}

class _FakeRepository extends JockeyInvitationRepository {
  _FakeRepository({
    this.invitations = const [],
    this.detail,
    List<JockeyInvitationDetail>? detailQueue,
    this.error,
    this.actionError,
  }) : detailQueue = detailQueue ?? const [];

  final List<JockeyInvitationListItem> invitations;
  final JockeyInvitationDetail? detail;
  final List<JockeyInvitationDetail> detailQueue;
  final Object? error;
  final Object? actionError;
  int listFetches = 0;
  int detailFetches = 0;
  int acceptCalls = 0;
  int rejectCalls = 0;
  String? lastNote;

  @override
  Future<List<JockeyInvitationListItem>> fetchInvitations() async {
    listFetches++;
    if (error != null) throw error!;
    return invitations;
  }

  @override
  Future<JockeyInvitationDetail> fetchInvitationDetail(String id) async {
    detailFetches++;
    if (error != null) throw error!;
    if (detailQueue.isNotEmpty) {
      final index = detailFetches - 1;
      return detailQueue[index < detailQueue.length
          ? index
          : detailQueue.length - 1];
    }
    return detail!;
  }

  @override
  Future<void> acceptInvitation(String id, {String? note}) async {
    acceptCalls++;
    lastNote = note;
    if (actionError != null) throw actionError!;
  }

  @override
  Future<void> rejectInvitation(String id, {String? note}) async {
    rejectCalls++;
    lastNote = note;
    if (actionError != null) throw actionError!;
  }
}
