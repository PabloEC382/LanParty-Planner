import '../dtos/game_dto.dart';

abstract class GamesLocalDao {
  /// Upsert em lote por id (insere novos e atualiza existentes).
  Future<void> upsertAll(List<GameDto> dtos);

  /// Lista todos os registros locais (DTOs).
  Future<List<GameDto>> listAll();

  /// Busca por id (DTO).
  Future<GameDto?> getById(String id);

  /// Limpa o cache (útil para reset/diagnóstico).
  Future<void> clear();
}
