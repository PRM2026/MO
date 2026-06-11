import '../models/role_application_response.dart';
import '../models/role_request_data.dart';
import '../repositories/auth_repository.dart';
import '../services/role_application_service.dart';

class RoleApplicationRepository {
  RoleApplicationRepository({
    RoleApplicationService? applicationService,
    AuthRepository? authRepository,
  })  : _applicationService = applicationService ?? RoleApplicationService(),
        _authRepository = authRepository ?? AuthRepository();

  final RoleApplicationService _applicationService;
  final AuthRepository _authRepository;

  Future<RoleRequestOverview> loadOverview() async {
    final user = await _authRepository.refreshCurrentUser();
    final history = await _loadHistory();

    return RoleRequestOverview(
      displayName: user.fullName?.trim().isNotEmpty == true
          ? user.fullName!.trim()
          : user.username ?? 'USER',
      profileImageUrl: user.avatarUrl,
      history: history,
    );
  }

  Future<List<RoleApplicationHistoryItem>> _loadHistory() async {
    try {
      final rawList = await _applicationService.getMyApplicationHistory();
      final items = rawList
          .map(RoleApplicationResponse.fromJson)
          .map((item) => item.toHistoryItem())
          .whereType<RoleApplicationHistoryItem>()
          .toList();
      if (items.isNotEmpty) return items;
    } catch (_) {}

    try {
      final raw = await _applicationService.getMyApplication();
      final item = RoleApplicationResponse.fromJson(raw).toHistoryItem();
      if (item != null) return [item];
    } catch (_) {}

    return const [];
  }
}
