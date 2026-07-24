import 'package:flutter_test/flutter_test.dart';
import 'package:horse_racing/src/models/jockey_invitation_data.dart';
import 'package:horse_racing/src/models/jockey_invitation_response.dart';
import 'package:horse_racing/src/repositories/jockey_invitation_repository.dart';
import 'package:horse_racing/src/services/jockey_invitation_service.dart';
import 'package:horse_racing/src/viewmodels/jockey_invitation_viewmodel.dart';

void main() {
  group('Jockey invitation mapping', () {
    test('maps only API-backed values with explicit fallbacks', () {
      const response = JockeyInvitationResponse(
        id: 7,
        ownerId: 3,
        jockeyId: 5,
        jockeyProfileId: 11,
        horseId: 21,
        status: 'PENDING',
        remunerationAmount: 500000,
      );

      final listItem = response.toListItem();
      final detail = response.toDetail();

      expect(listItem.horseName, 'Ngựa chưa cập nhật');
      expect(listItem.raceName, 'Chưa gắn cuộc đua');
      expect(listItem.tournamentName, 'Chưa gắn giải đấu');
      expect(listItem.remunerationLabel, '500.000 đ');
      expect(detail.horseReference, 'Ngựa #21');
      expect(detail.ownerReference, 'Chủ ngựa #3');
      expect(detail.message, 'Không có lời nhắn kèm theo.');
      expect(detail.respondedAtLabel, isEmpty);
      expect(detail.cancelledAtLabel, isEmpty);
    });
  });

  group('JockeyInvitationsViewModel', () {
    test('defaults to all and filters without changing source order', () async {
      final repository = _FakeRepository(
        invitations: const [
          JockeyInvitationListItem(
            id: '3',
            horseName: 'Horse 3',
            ownerName: 'Owner',
            raceName: 'Race',
            tournamentName: 'Cup',
            remunerationLabel: '300.000 đ',
            createdAtLabel: '18/06/2026 10:00',
            statusCode: 'CANCELLED',
            statusLabel: 'Đã hủy',
          ),
          JockeyInvitationListItem(
            id: '2',
            horseName: 'Horse 2',
            ownerName: 'Owner',
            raceName: 'Race',
            tournamentName: 'Cup',
            remunerationLabel: '200.000 đ',
            createdAtLabel: '18/06/2026 09:00',
            statusCode: 'ACCEPTED',
            statusLabel: 'Đã nhận',
          ),
          JockeyInvitationListItem(
            id: '1',
            horseName: 'Horse 1',
            ownerName: 'Owner',
            raceName: 'Race',
            tournamentName: 'Cup',
            remunerationLabel: '100.000 đ',
            createdAtLabel: '18/06/2026 08:00',
            statusCode: 'PENDING',
            statusLabel: 'Chờ phản hồi',
          ),
        ],
      );
      final viewModel = JockeyInvitationsViewModel(repository: repository);

      await viewModel.loadInvitations();

      expect(viewModel.selectedFilter, JockeyInvitationFilter.all);
      expect(viewModel.visibleInvitations.map((item) => item.id), [
        '3',
        '2',
        '1',
      ]);

      viewModel.selectFilter(JockeyInvitationFilter.pending);
      expect(viewModel.visibleInvitations.single.id, '1');
      expect(viewModel.invitations, hasLength(3));

      viewModel.selectFilter(JockeyInvitationFilter.rejected);
      expect(viewModel.visibleInvitations, isEmpty);
      expect(viewModel.emptyMessage, contains('từ chối'));
    });

    test('exposes API error and clears loading state', () async {
      final viewModel = JockeyInvitationsViewModel(
        repository: _FakeRepository(
          error: const JockeyInvitationApiException('Backend unavailable'),
        ),
      );

      await viewModel.loadInvitations();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.invitations, isEmpty);
      expect(viewModel.loadError, 'Backend unavailable');
    });
  });

  group('JockeyInvitationDetailViewModel', () {
    test('loads detail data', () async {
      final detail = _detail();
      final viewModel = JockeyInvitationDetailViewModel(
        invitationId: '7',
        repository: _FakeRepository(detail: detail),
      );

      await viewModel.loadDetail();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.loadError, isNull);
      expect(viewModel.data, same(detail));
    });

    test('invalid id does not call service', () async {
      final service = _RecordingService();
      final viewModel = JockeyInvitationDetailViewModel(
        invitationId: 'invalid',
        repository: JockeyInvitationRepository(service: service),
      );

      await viewModel.loadDetail();

      expect(service.detailCalls, 0);
      expect(viewModel.data, isNull);
      expect(viewModel.loadError, 'Không xác định được mã lời mời.');
    });

    test('note longer than 1000 is rejected without repository call', () async {
      final repository = _FakeRepository(detail: _detail());
      final viewModel = JockeyInvitationDetailViewModel(
        invitationId: '7',
        repository: repository,
      );

      final success = await viewModel.acceptInvitation(note: 'x' * 1001);

      expect(success, isFalse);
      expect(repository.acceptCalls, 0);
      expect(viewModel.actionError, 'Ghi chú tối đa 1000 ký tự.');
    });

    test('accept success reloads detail and marks action completed', () async {
      final pending = _detail(
        statusCode: 'PENDING',
        statusLabel: 'Chờ phản hồi',
      );
      final accepted = _detail(
        statusCode: 'ACCEPTED',
        statusLabel: 'Đã nhận',
        responseNote: 'Ready',
      );
      final repository = _FakeRepository(detailQueue: [pending, accepted]);
      final viewModel = JockeyInvitationDetailViewModel(
        invitationId: '7',
        repository: repository,
      );

      await viewModel.loadDetail();
      final success = await viewModel.acceptInvitation(note: ' Ready ');

      expect(success, isTrue);
      expect(repository.acceptCalls, 1);
      expect(repository.lastNote, 'Ready');
      expect(repository.detailFetches, 2);
      expect(viewModel.data, same(accepted));
      expect(viewModel.actionCompleted, isTrue);
      expect(viewModel.isProcessing, isFalse);
      expect(viewModel.actionError, isNull);
    });

    test(
      'reject action error keeps current detail and exposes message',
      () async {
        final pending = _detail(
          statusCode: 'PENDING',
          statusLabel: 'Chờ phản hồi',
        );
        final repository = _FakeRepository(
          detail: pending,
          actionError: const JockeyInvitationApiException(
            'Invitation is no longer pending',
          ),
        );
        final viewModel = JockeyInvitationDetailViewModel(
          invitationId: '7',
          repository: repository,
        );

        await viewModel.loadDetail();
        final success = await viewModel.rejectInvitation(note: 'Busy');

        expect(success, isFalse);
        expect(repository.rejectCalls, 1);
        expect(viewModel.data, same(pending));
        expect(viewModel.actionCompleted, isFalse);
        expect(viewModel.isProcessing, isFalse);
        expect(viewModel.actionError, 'Invitation is no longer pending');
      },
    );
  });
}

JockeyInvitationDetail _detail({
  String statusCode = 'PENDING',
  String statusLabel = 'Chờ phản hồi',
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
    statusCode: statusCode,
    statusLabel: statusLabel,
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
  int detailFetches = 0;
  int acceptCalls = 0;
  int rejectCalls = 0;
  String? lastNote;

  @override
  Future<List<JockeyInvitationListItem>> fetchInvitations() async {
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

class _RecordingService extends JockeyInvitationService {
  int detailCalls = 0;

  @override
  Future<JockeyInvitationResponse> getJockeyInvitation(String id) async {
    detailCalls++;
    return const JockeyInvitationResponse(id: '7');
  }
}
