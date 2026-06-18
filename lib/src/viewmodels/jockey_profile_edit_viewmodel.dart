import 'package:flutter/foundation.dart';

import '../models/jockey_profile_response.dart';
import '../repositories/jockey_profile_repository.dart';
import '../services/api_exception.dart';
import '../utils/jockey_profile_update_validation.dart';

class JockeyProfileEditInput {
  const JockeyProfileEditInput({
    required this.licenseNumber,
    required this.experienceYears,
    required this.heightCm,
    required this.weightKg,
    required this.bio,
    required this.awards,
    required this.specialties,
  });

  factory JockeyProfileEditInput.fromProfile(JockeyProfileResponse profile) {
    return JockeyProfileEditInput(
      licenseNumber: profile.licenseNumber ?? '',
      experienceYears: _numberText(profile.experienceYears),
      heightCm: _numberText(profile.heightCm),
      weightKg: _numberText(profile.weightKg),
      bio: profile.bio ?? '',
      awards: profile.awards ?? '',
      specialties: profile.specialties ?? '',
    );
  }

  factory JockeyProfileEditInput.fromFields(Map<String, String> fields) {
    return JockeyProfileEditInput(
      licenseNumber: fields['licenseNumber'] ?? '',
      experienceYears: fields['experienceYears'] ?? '',
      heightCm: fields['heightCm'] ?? '',
      weightKg: fields['weightKg'] ?? '',
      bio: fields['bio'] ?? '',
      awards: fields['awards'] ?? '',
      specialties: fields['specialties'] ?? '',
    );
  }

  final String licenseNumber;
  final String experienceYears;
  final String heightCm;
  final String weightKg;
  final String bio;
  final String awards;
  final String specialties;

  Map<String, String> toFields() {
    return {
      'licenseNumber': licenseNumber,
      'experienceYears': experienceYears,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'bio': bio,
      'awards': awards,
      'specialties': specialties,
    };
  }

  static String _numberText(num value) {
    if (value == 0) return '0';
    if (value % 1 == 0) return value.toInt().toString();
    return value.toString();
  }
}

class JockeyProfileFilePaths {
  const JockeyProfileFilePaths({
    this.avatar,
    this.achievements,
    this.licenseDocument,
  });

  final String? avatar;
  final String? achievements;
  final String? licenseDocument;

  Map<String, String> toFiles() {
    return {
      if (avatar?.isNotEmpty == true) 'avatar': avatar!,
      if (achievements?.isNotEmpty == true) 'achievements': achievements!,
      if (licenseDocument?.isNotEmpty == true)
        'licenseDocument': licenseDocument!,
    };
  }
}

class JockeyProfileUpdateCommand {
  const JockeyProfileUpdateCommand({
    required this.fields,
    required this.filePaths,
  });

  final Map<String, String> fields;
  final Map<String, String> filePaths;

  bool get isEmpty => fields.isEmpty && filePaths.isEmpty;
}

class JockeyProfileEditViewModel extends ChangeNotifier {
  JockeyProfileEditViewModel({
    required this.initialProfile,
    JockeyProfileRepository? repository,
  }) : _repository = repository ?? JockeyProfileRepository();

  final JockeyProfileResponse initialProfile;
  final JockeyProfileRepository _repository;

  bool isSubmitting = false;
  String? submitError;

  late final JockeyProfileEditInput initialInput =
      JockeyProfileEditInput.fromProfile(initialProfile);

  Map<String, String> get initialValues => initialInput.toFields();

  bool isDirty({
    required JockeyProfileEditInput input,
    required JockeyProfileFilePaths filePaths,
  }) {
    return !buildCommand(input: input, filePaths: filePaths).isEmpty;
  }

  String? validate(JockeyProfileEditInput input) {
    final values = input.toFields();
    final changed = _changedFields(values);
    if (changed.containsKey('licenseNumber') &&
        changed['licenseNumber']!.trim().isEmpty) {
      return 'License number khong duoc de trong khi cap nhat.';
    }
    return JockeyProfileUpdateValidation.validateFields(values);
  }

  JockeyProfileUpdateCommand buildCommand({
    required JockeyProfileEditInput input,
    required JockeyProfileFilePaths filePaths,
  }) {
    return JockeyProfileUpdateCommand(
      fields: _changedFields(input.toFields()),
      filePaths: filePaths.toFiles(),
    );
  }

  void clearSubmitError() {
    if (submitError == null) return;
    submitError = null;
    notifyListeners();
  }

  Future<JockeyProfileResponse?> submit({
    required JockeyProfileEditInput input,
    required JockeyProfileFilePaths filePaths,
  }) async {
    if (isSubmitting) return null;

    final validationError = validate(input);
    if (validationError != null) {
      submitError = validationError;
      notifyListeners();
      return null;
    }

    final command = buildCommand(input: input, filePaths: filePaths);

    if (command.isEmpty) {
      submitError = 'Chua co thay doi de luu.';
      notifyListeners();
      return null;
    }

    isSubmitting = true;
    submitError = null;
    notifyListeners();

    try {
      return await _repository.updateProfile(
        fields: command.fields,
        filePaths: command.filePaths,
      );
    } on ApiException catch (error) {
      submitError = error.message;
      return null;
    } catch (error) {
      if (kDebugMode) debugPrint('JockeyProfileEditViewModel: $error');
      submitError = 'Khong the cap nhat ho so jockey.';
      return null;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Map<String, String> _changedFields(Map<String, String> values) {
    final initial = initialValues;
    final changed = <String, String>{};

    for (final field in JockeyProfileUpdateValidation.fieldNames) {
      final current = values[field] ?? '';
      if (current != initial[field]) {
        if (_numericFields.contains(field) && current.trim().isEmpty) {
          continue;
        }
        changed[field] = current;
      }
    }

    return changed;
  }

  static const _numericFields = {'experienceYears', 'heightCm', 'weightKg'};
}
