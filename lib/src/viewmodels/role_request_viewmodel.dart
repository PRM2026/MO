import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/role_request_data.dart';
import '../repositories/auth_repository.dart';
import '../repositories/role_application_repository.dart';
import '../services/role_application_service.dart';

class RoleRequestViewModel extends ChangeNotifier {
  RoleRequestViewModel({
    AuthRepository? authRepository,
    RoleApplicationService? applicationService,
    RoleApplicationRepository? repository,
  }) : _authRepository = authRepository ?? AuthRepository(),
       _applicationService = applicationService ?? RoleApplicationService(),
       _repository =
           repository ??
           RoleApplicationRepository(
             authRepository: authRepository,
             applicationService: applicationService,
           );

  final AuthRepository _authRepository;
  final RoleApplicationService _applicationService;
  final RoleApplicationRepository _repository;

  bool isLoading = false;
  bool isSubmitting = false;
  RoleRequestOverview? overview;
  String? submitError;
  String? loadError;

  Future<void> loadData() async {
    isLoading = true;
    loadError = null;
    notifyListeners();

    try {
      overview = await _repository.loadOverview();
    } catch (error) {
      loadError = 'Không tải được dữ liệu yêu cầu vai trò.';
      if (kDebugMode) debugPrint('RoleRequestViewModel.loadData: $error');
      final profile = await _authRepository.loadProfile();
      overview = RoleRequestOverview.empty(
        displayName: profile.fullName?.trim().isNotEmpty == true
            ? profile.fullName!.trim()
            : 'USER',
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> submitApplication(
    SystemRoleType role,
    Map<String, String> values,
    Map<String, File> files,
  ) async {
    isSubmitting = true;
    submitError = null;
    notifyListeners();

    try {
      await _applicationService.submitRole(role, values, files);
      await _authRepository.refreshCurrentUser();
      await loadData();
      return null;
    } on RoleApplicationApiException catch (error) {
      submitError = error.message;
      return error.message;
    } catch (error) {
      submitError = 'Gửi hồ sơ thất bại. Vui lòng thử lại.';
      if (kDebugMode) debugPrint('RoleRequestViewModel.submit: $error');
      return submitError;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }
}
