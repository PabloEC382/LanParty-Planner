import '../dtos/tournament_dto.dart';

abstract class TournamentsLocalDao {
  /// Upsert em lote por id (insere novos e atualiza existentes).
  Future<void> upsertAll(List<TournamentDto> dtos);

  /// Lista todos os registros locais (DTOs).
  Future<List<TournamentDto>> listAll();

  /// Busca por id (DTO).
  Future<TournamentDto?> getById(String id);

  /// Limpa o cache (útil para reset/diagnóstico).
  Future<void> clear();
}
