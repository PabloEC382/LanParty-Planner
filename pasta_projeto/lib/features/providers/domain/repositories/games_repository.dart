import '../entities/game.dart';

abstract class GamesRepository {
  /// Lista todos os jogos
  Future<List<Game>> listAll();

  /// Busca um jogo por ID
  Future<Game?> getById(String id);

  /// Cria um novo jogo
  Future<Game> create(Game game);

  /// Atualiza um jogo existente
  Future<Game> update(Game game);

  /// Deleta um jogo por ID
  Future<void> delete(String id);

  /// Busca jogos por gênero
  Future<List<Game>> findByGenre(String genre);

  /// Busca jogos populares (baseado em totalMatches)
  Future<List<Game>> findPopular({int limit = 10});

  /// Sincroniza jogos locais com o servidor
  Future<void> sync();

  /// Limpa o cache local
  Future<void> clearCache();
}
