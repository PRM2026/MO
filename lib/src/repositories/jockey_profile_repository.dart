import '../models/jockey_profile_response.dart';
import '../services/jockey_profile_service.dart';

class JockeyProfileRepository {
  JockeyProfileRepository({JockeyProfileService? service})
    : _service = service ?? JockeyProfileService();

  final JockeyProfileService _service;

  Future<JockeyProfileResponse> fetchProfile() {
    return _service.getMyProfile();
  }

  Future<JockeyProfileResponse> updateProfile({
    required Map<String, String> fields,
    Map<String, String> filePaths = const {},
  }) {
    return _service.updateMyProfile(fields: fields, filePaths: filePaths);
  }
}
