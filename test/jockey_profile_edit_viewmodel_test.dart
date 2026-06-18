import 'package:flutter_test/flutter_test.dart';
import 'package:horse_racing/src/models/jockey_profile_response.dart';
import 'package:horse_racing/src/repositories/jockey_profile_repository.dart';
import 'package:horse_racing/src/services/api_exception.dart';
import 'package:horse_racing/src/utils/jockey_profile_update_validation.dart';
import 'package:horse_racing/src/viewmodels/jockey_profile_edit_viewmodel.dart';

void main() {
  group('JockeyProfileUpdateValidation', () {
    test('validates text limits and numeric fields', () {
      expect(
        JockeyProfileUpdateValidation.validateFields({
          ..._input().toFields(),
          'licenseNumber': 'x' * 101,
        }),
        isNotNull,
      );
      expect(
        JockeyProfileUpdateValidation.validateFields({
          ..._input().toFields(),
          'experienceYears': '-1',
        }),
        isNotNull,
      );
      expect(
        JockeyProfileUpdateValidation.validateFields({
          ..._input().toFields(),
          'experienceYears': '1.5',
        }),
        isNotNull,
      );
      expect(
        JockeyProfileUpdateValidation.validateFields({
          ..._input().toFields(),
          'heightCm': 'not-a-number',
        }),
        isNotNull,
      );
      expect(
        JockeyProfileUpdateValidation.validateFields({
          ..._input().toFields(),
          'weightKg': '54.5',
        }),
        isNull,
      );
      expect(
        JockeyProfileUpdateValidation.validateFields({
          ..._input().toFields(),
          'bio': 'x' * 1001,
        }),
        isNotNull,
      );
      expect(
        JockeyProfileUpdateValidation.validateFields({
          ..._input().toFields(),
          'awards': 'x' * 2001,
        }),
        isNotNull,
      );
      expect(
        JockeyProfileUpdateValidation.validateFields({
          ..._input().toFields(),
          'specialties': 'x' * 1001,
        }),
        isNotNull,
      );
    });

    test('validates file extensions and size limits', () {
      expect(
        JockeyProfileUpdateValidation.validateFile(
          'avatar',
          5 * 1024 * 1024,
          'JPG',
        ),
        isNull,
      );
      expect(
        JockeyProfileUpdateValidation.validateFile('achievements', 1, 'pdf'),
        isNotNull,
      );
      expect(
        JockeyProfileUpdateValidation.validateFile(
          'avatar',
          5 * 1024 * 1024 + 1,
          'png',
        ),
        isNotNull,
      );
      expect(
        JockeyProfileUpdateValidation.validateFile(
          'licenseDocument',
          10 * 1024 * 1024,
          'pdf',
        ),
        isNull,
      );
      expect(
        JockeyProfileUpdateValidation.validateFile(
          'licenseDocument',
          10 * 1024 * 1024 + 1,
          'webp',
        ),
        isNotNull,
      );
    });
  });

  group('JockeyProfileEditViewModel', () {
    test('prefills input and is not dirty initially', () {
      final viewModel = JockeyProfileEditViewModel(
        initialProfile: _profile(),
        repository: _RecordingRepository(response: _profile()),
      );

      expect(viewModel.initialInput.licenseNumber, 'JCK-2026-001');
      expect(viewModel.initialInput.experienceYears, '7');
      expect(viewModel.initialInput.heightCm, '168.5');
      expect(viewModel.initialInput.weightKg, '54');
      expect(
        viewModel.isDirty(
          input: viewModel.initialInput,
          filePaths: const JockeyProfileFilePaths(),
        ),
        isFalse,
      );
    });

    test('builds command with changed fields and exact file keys', () {
      final viewModel = JockeyProfileEditViewModel(
        initialProfile: _profile(),
        repository: _RecordingRepository(response: _profile()),
      );

      final command = viewModel.buildCommand(
        input: _input(bio: '', heightCm: ''),
        filePaths: const JockeyProfileFilePaths(
          avatar: 'avatar.jpg',
          achievements: 'achievements.png',
          licenseDocument: 'license.pdf',
        ),
      );

      expect(command.fields['bio'], '');
      expect(command.fields.containsKey('heightCm'), isFalse);
      expect(command.fields.containsKey('licenseNumber'), isFalse);
      expect(command.filePaths, {
        'avatar': 'avatar.jpg',
        'achievements': 'achievements.png',
        'licenseDocument': 'license.pdf',
      });
    });

    test('rejects blank license number only when it changed', () {
      final viewModel = JockeyProfileEditViewModel(
        initialProfile: _profile(),
        repository: _RecordingRepository(response: _profile()),
      );

      expect(viewModel.validate(_input(licenseNumber: '   ')), isNotNull);
      expect(viewModel.validate(viewModel.initialInput), isNull);
    });

    test('does not submit when form is not dirty', () async {
      final repository = _RecordingRepository(response: _profile());
      final viewModel = JockeyProfileEditViewModel(
        initialProfile: _profile(),
        repository: repository,
      );

      final result = await viewModel.submit(
        input: viewModel.initialInput,
        filePaths: const JockeyProfileFilePaths(),
      );

      expect(result, isNull);
      expect(repository.callCount, 0);
      expect(viewModel.submitError, 'Chua co thay doi de luu.');
    });

    test('submit success returns updated profile', () async {
      final updated = _profile(status: 'PENDING', bio: 'Updated bio');
      final repository = _RecordingRepository(response: updated);
      final viewModel = JockeyProfileEditViewModel(
        initialProfile: _profile(),
        repository: repository,
      );

      final result = await viewModel.submit(
        input: _input(bio: 'Updated bio'),
        filePaths: const JockeyProfileFilePaths(avatar: 'avatar.jpg'),
      );

      expect(result, same(updated));
      expect(viewModel.isSubmitting, isFalse);
      expect(viewModel.submitError, isNull);
      expect(repository.fields, {'bio': 'Updated bio'});
      expect(repository.filePaths, {'avatar': 'avatar.jpg'});
    });

    test('submit ApiException keeps input state and exposes message', () async {
      final repository = _RecordingRepository(
        error: const ApiException('License number already exists'),
      );
      final viewModel = JockeyProfileEditViewModel(
        initialProfile: _profile(),
        repository: repository,
      );
      final input = _input(licenseNumber: 'DUPLICATE');

      final result = await viewModel.submit(
        input: input,
        filePaths: const JockeyProfileFilePaths(),
      );

      expect(result, isNull);
      expect(viewModel.isSubmitting, isFalse);
      expect(viewModel.submitError, 'License number already exists');
      expect(input.licenseNumber, 'DUPLICATE');
    });
  });
}

JockeyProfileEditInput _input({
  String licenseNumber = 'JCK-2026-001',
  String experienceYears = '7',
  String heightCm = '168.5',
  String weightKg = '54',
  String bio = 'Professional jockey',
  String awards = 'National Cup 2025',
  String specialties = 'Sprint',
}) {
  return JockeyProfileEditInput(
    licenseNumber: licenseNumber,
    experienceYears: experienceYears,
    heightCm: heightCm,
    weightKg: weightKg,
    bio: bio,
    awards: awards,
    specialties: specialties,
  );
}

JockeyProfileResponse _profile({
  String status = 'APPROVED',
  String bio = 'Professional jockey',
}) {
  return JockeyProfileResponse(
    id: 11,
    userId: 5,
    username: 'minh_jockey',
    fullName: 'Minh Nguyen',
    licenseNumber: 'JCK-2026-001',
    experienceYears: 7,
    heightCm: 168.5,
    weightKg: 54,
    bio: bio,
    awards: 'National Cup 2025',
    achievements: 'https://example.test/achievement.png',
    specialties: 'Sprint',
    status: status,
    performance: JockeyProfilePerformance.empty(),
    raceHistory: const [],
  );
}

class _RecordingRepository extends JockeyProfileRepository {
  _RecordingRepository({this.response, this.error});

  final JockeyProfileResponse? response;
  final Object? error;
  int callCount = 0;
  Map<String, String>? fields;
  Map<String, String>? filePaths;

  @override
  Future<JockeyProfileResponse> updateProfile({
    required Map<String, String> fields,
    Map<String, String> filePaths = const {},
  }) async {
    callCount++;
    this.fields = fields;
    this.filePaths = filePaths;
    if (error != null) throw error!;
    return response!;
  }
}
