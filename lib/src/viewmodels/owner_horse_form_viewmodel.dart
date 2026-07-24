import 'package:flutter/foundation.dart';

import '../models/owner_horse_item.dart';
import '../repositories/owner_horse_repository.dart';

class OwnerHorseFormViewModel extends ChangeNotifier {
  OwnerHorseFormViewModel({
    this.initialDetail,
    OwnerHorseRepository? repository,
  }) : _repository = repository ?? OwnerHorseRepository();

  final OwnerHorseDetail? initialDetail;
  final OwnerHorseRepository _repository;

  bool isSubmitting = false;
  String? submitError;

  bool get isEdit => initialDetail != null;

  String? validate({
    required String name,
    required String breed,
    required String age,
    required String gender,
    required String color,
    required String heightCm,
    required String weightKg,
  }) {
    final trimmedName = name.trim();
    if (!isEdit && trimmedName.isEmpty) {
      return 'Vui lòng nhập tên ngựa.';
    }
    if (trimmedName.length > 120) {
      return 'Tên ngựa tối đa 120 ký tự.';
    }
    if (breed.trim().length > 120) {
      return 'Giống ngựa tối đa 120 ký tự.';
    }
    if (gender.trim().length > 40) {
      return 'Giới tính tối đa 40 ký tự.';
    }
    if (color.trim().length > 80) {
      return 'Màu lông tối đa 80 ký tự.';
    }

    final ageValue = _parseInt(age);
    if (age.trim().isNotEmpty && ageValue == null) {
      return 'Tuổi phải là số nguyên.';
    }
    if (ageValue != null && ageValue < 0) {
      return 'Tuổi không được nhỏ hơn 0.';
    }

    final heightValue = _parseDouble(heightCm);
    if (heightCm.trim().isNotEmpty && heightValue == null) {
      return 'Chiều cao phải là số.';
    }
    if (heightValue != null && heightValue <= 0) {
      return 'Chiều cao phải lớn hơn 0.';
    }

    final weightValue = _parseDouble(weightKg);
    if (weightKg.trim().isNotEmpty && weightValue == null) {
      return 'Cân nặng phải là số.';
    }
    if (weightValue != null && weightValue <= 0) {
      return 'Cân nặng phải lớn hơn 0.';
    }

    return null;
  }

  Future<bool> submit({
    required String name,
    required String breed,
    required String age,
    required String gender,
    required String color,
    required String heightCm,
    required String weightKg,
    String? imagePath,
    Uint8List? imageBytes,
    String? imageName,
    String? documentPath,
    Uint8List? documentBytes,
    String? documentName,
  }) async {
    submitError = validate(
      name: name,
      breed: breed,
      age: age,
      gender: gender,
      color: color,
      heightCm: heightCm,
      weightKg: weightKg,
    );
    if (submitError != null) {
      notifyListeners();
      return false;
    }

    isSubmitting = true;
    submitError = null;
    notifyListeners();

    final data = OwnerHorseFormData(
      name: _emptyToNull(name),
      breed: _emptyToNull(breed),
      age: _parseInt(age),
      gender: _emptyToNull(gender),
      color: _emptyToNull(color),
      heightCm: _parseDouble(heightCm),
      weightKg: _parseDouble(weightKg),
      imagePath: _emptyToNull(imagePath),
      imageBytes: imageBytes,
      imageName: _emptyToNull(imageName),
      documentPath: _emptyToNull(documentPath),
      documentBytes: documentBytes,
      documentName: _emptyToNull(documentName),
    );

    try {
      if (isEdit) {
        await _repository.updateHorse(initialDetail!.id, data);
      } else {
        await _repository.createHorse(data);
      }
      return true;
    } catch (error) {
      submitError = _messageFrom(error, 'Không thể lưu thông tin ngựa.');
      if (kDebugMode) debugPrint('OwnerHorseFormViewModel: $error');
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  String? _emptyToNull(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  int? _parseInt(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return int.tryParse(trimmed);
  }

  double? _parseDouble(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return double.tryParse(trimmed.replaceAll(',', '.'));
  }

  String _messageFrom(Object error, String fallback) {
    final text = error.toString().trim();
    if (text.isEmpty) return fallback;
    return text
        .replaceFirst('OwnerApiException: ', '')
        .replaceFirst('ApiException: ', '')
        .replaceFirst('Exception: ', '');
  }
}
