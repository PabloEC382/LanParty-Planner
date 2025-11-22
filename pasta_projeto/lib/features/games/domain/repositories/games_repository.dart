import '../entities/game.dart';

abstract class GamesRepository {
  Future<List<Game>> listAll();
  Future<Game?> getById(String id);
  Future<Game> create(Game game);
  Future<Game> update(Game game);
  Future<void> delete(String id);
  Future<void> sync();
  Future<void> clearCache();
}
