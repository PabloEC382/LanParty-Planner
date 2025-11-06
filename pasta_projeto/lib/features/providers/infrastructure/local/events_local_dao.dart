import '../dtos/event_dto.dart';

abstract class EventsLocalDao {
  /// Upsert em lote por id (insere novos e atualiza existentes).
  Future<void> upsertAll(List<EventDto> dtos);

  /// Lista todos os registros locais (DTOs).
  Future<List<EventDto>> listAll();

  /// Busca por id (DTO).
  Future<EventDto?> getById(String id);

  /// Limpa o cache (útil para reset/diagnóstico).
  Future<void> clear();
}
