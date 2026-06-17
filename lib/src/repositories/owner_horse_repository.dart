import '../models/owner_horse_item.dart';
import '../services/owner_horse_service.dart';

class OwnerHorseRepository {
  OwnerHorseRepository({OwnerHorseService? service})
    : _service = service ?? OwnerHorseService();

  final OwnerHorseService _service;

  Future<List<OwnerHorseItem>> fetchHorses() async {
    return _service.getOwnerHorses();
  }

  Future<OwnerHorseDetail> fetchHorse(String id) {
    return _service.getOwnerHorse(id);
  }

  Future<OwnerHorseDetail> createHorse(OwnerHorseFormData data) {
    return _service.createHorse(data);
  }

  Future<OwnerHorseDetail> updateHorse(String id, OwnerHorseFormData data) {
    return _service.updateHorse(id, data);
  }

  Future<void> deleteHorse(String id) {
    return _service.deleteHorse(id);
  }
}
