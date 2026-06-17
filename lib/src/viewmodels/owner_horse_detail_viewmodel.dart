import 'package:flutter/foundation.dart';

import '../models/owner_horse_item.dart';
import '../repositories/owner_horse_repository.dart';

class OwnerHorseDetailViewModel extends ChangeNotifier {
  OwnerHorseDetailViewModel({
    required this.horseId,
    OwnerHorseRepository? repository,
  }) : _repository = repository ?? OwnerHorseRepository();

  final String horseId;
  final OwnerHorseRepository _repository;

  bool isLoading = false;
  bool isDeleting = false;
  String? errorMessage;
  String? deleteError;
  OwnerHorseDetail? detail;

  Future<void> loadDetail() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      detail = await _repository.fetchHorse(horseId);
    } catch (error) {
      detail = null;
      errorMessage = _messageFrom(error, 'Không thể tải chi tiết ngựa.');
      if (kDebugMode) debugPrint('OwnerHorseDetailViewModel: $error');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => loadDetail();

  Future<bool> deleteHorse() async {
    isDeleting = true;
    deleteError = null;
    notifyListeners();

    try {
      await _repository.deleteHorse(horseId);
      return true;
    } catch (error) {
      deleteError = _messageFrom(error, 'Không thể xóa ngựa.');
      if (kDebugMode) debugPrint('OwnerHorseDetailViewModel delete: $error');
      return false;
    } finally {
      isDeleting = false;
      notifyListeners();
    }
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
