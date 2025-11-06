import '../entities/tournament.dart';

abstract class TournamentsRepository {
  /// Lista todos os torneios
  Future<List<Tournament>> listAll();

  /// Busca um torneio por ID
  Future<Tournament?> getById(String id);

  /// Cria um novo torneio
  Future<Tournament> create(Tournament tournament);

  /// Atualiza um torneio existente
  Future<Tournament> update(Tournament tournament);

  /// Deleta um torneio por ID
  Future<void> delete(String id);

  /// Busca torneios por status
  Future<List<Tournament>> findByStatus(TournamentStatus status);

  /// Busca torneios por jogo
  Future<List<Tournament>> findByGame(String gameId);

  /// Busca torneios abertos para inscrição
  Future<List<Tournament>> findOpenForRegistration();

  /// Busca torneios em andamento
  Future<List<Tournament>> findInProgress();

  /// Sincroniza torneios locais com o servidor
  Future<void> sync();

  /// Limpa o cache local
  Future<void> clearCache();
}
