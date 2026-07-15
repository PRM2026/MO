import 'package:flutter/foundation.dart';

import '../models/spectator_models.dart';
import '../repositories/spectator_repository.dart';

class SpectatorProfileViewModel extends ChangeNotifier {
  SpectatorProfileViewModel({SpectatorRepository? repository})
    : _repository = repository ?? SpectatorRepository();

  final SpectatorRepository _repository;

  bool isLoading = false;
  String? errorMessage;
  SpectatorProfileData? data;

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final user = await _repository.fetchCurrentUser();
      data = SpectatorProfileData.fromUserProfile(user);
    } catch (error) {
      if (kDebugMode) debugPrint('SpectatorProfileViewModel: $error');
      data = null;
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> retry() => load();
}
