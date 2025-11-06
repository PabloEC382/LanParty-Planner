import '../dtos/participant_dto.dart';

abstract class ParticipantsLocalDao {
  /// Upsert em lote por id (insere novos e atualiza existentes).
  Future<void> upsertAll(List<ParticipantDto> dtos);

  /// Lista todos os registros locais (DTOs).
  Future<List<ParticipantDto>> listAll();

  /// Busca por id (DTO).
  Future<ParticipantDto?> getById(String id);

  /// Limpa o cache (útil para reset/diagnóstico).
  Future<void> clear();
}
