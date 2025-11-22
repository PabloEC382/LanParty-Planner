import '../dtos/venue_dto.dart';

abstract class VenuesLocalDao {
  Future<void> upsertAll(List<VenueDto> dtos);
  Future<void> clear();
  Future<VenueDto?> getById(String id);
  Future<List<VenueDto>> listAll();
}
