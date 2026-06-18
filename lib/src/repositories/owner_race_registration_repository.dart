import '../models/owner_race_registration.dart';
import '../services/owner_race_registration_service.dart';

class OwnerRaceRegistrationRepository {
  OwnerRaceRegistrationRepository({OwnerRaceRegistrationService? service})
    : _service = service ?? OwnerRaceRegistrationService();

  final OwnerRaceRegistrationService _service;

  Future<List<OwnerEligibleHorseTeam>> fetchEligibleTeams() =>
      _service.getEligibleTeams();

  Future<OwnerRaceRegistration> registerRace(
    String raceId,
    OwnerRaceRegistrationFormData data,
  ) => _service.registerRace(raceId, data);

  Future<List<OwnerRaceRegistration>> fetchRegistrations() =>
      _service.getRegistrations();

  Future<OwnerRaceRegistration> withdrawRegistration(
    String id,
    OwnerRaceRegistrationWithdrawData data,
  ) => _service.withdrawRegistration(id, data);
}
