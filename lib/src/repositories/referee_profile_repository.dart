import '../models/referee_profile_data.dart';
import '../models/stored_auth_profile.dart';
import 'auth_repository.dart';

class RefereeProfileRepository {
  RefereeProfileRepository({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  final AuthRepository _authRepository;

  Future<RefereeProfileData> fetchProfile() async {
    final StoredAuthProfile auth = await _authRepository.loadProfile();
    final fullName = auth.fullName?.trim().isNotEmpty == true
        ? auth.fullName!.trim()
        : 'Nguyễn Văn A';

    return RefereeProfileData.sample(fullName: fullName);
  }
}
