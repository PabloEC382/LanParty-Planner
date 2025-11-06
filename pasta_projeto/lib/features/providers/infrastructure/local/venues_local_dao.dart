import '../dtos/venue_dto.dart';

abstract class VenuesLocalDao {
  /// Upsert em lote por id (insere novos e atualiza existentes).
  Future<void> upsertAll(List<VenueDto> dtos);

  /// Lista todos os registros locais (DTOs).
  Future<List<VenueDto>> listAll();

  /// Busca por id (DTO).
  Future<VenueDto?> getById(String id);

  /// Limpa o cache (útil para reset/diagnóstico).
  Future<void> clear();
}
