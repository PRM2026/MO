import '../models/owner_horse_item.dart';
import '../services/owner_horse_service.dart';

class OwnerHorseRepository {
  OwnerHorseRepository({OwnerHorseService? service})
      : _service = service ?? OwnerHorseService();

  final OwnerHorseService _service;

  Future<List<OwnerHorseItem>> fetchHorses() async {
    return _service.getOwnerHorses();
  }
}
