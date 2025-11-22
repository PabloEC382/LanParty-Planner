import '../../domain/entities/game.dart';
import '../../domain/repositories/games_repository.dart';
import '../mappers/game_mapper.dart';
import '../local/games_local_dao_shared_prefs.dart';

class GamesRepositoryImpl implements GamesRepository {
  final GamesLocalDaoSharedPrefs _localDao;

  GamesRepositoryImpl({required GamesLocalDaoSharedPrefs localDao})
      : _localDao = localDao;

  @override
  Future<Game> create(Game game) async {
    try {
      final dto = GameMapper.toDto(game);
      final currentList = await _localDao.listAll();
      currentList.add(dto);
      await _localDao.upsertAll(currentList);
      return game;
    } catch (e) {
      throw Exception('Erro ao criar jogo: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      final currentList = await _localDao.listAll();
      currentList.removeWhere((dto) => dto.id == id);
      await _localDao.upsertAll(currentList);
    } catch (e) {
      throw Exception('Erro ao deletar jogo: $e');
    }
  }

  @override
  Future<Game?> getById(String id) async {
    try {
      final dto = await _localDao.getById(id);
      return dto != null ? GameMapper.toEntity(dto) : null;
    } catch (e) {
      throw Exception('Erro ao buscar jogo: $e');
    }
  }

  @override
  Future<List<Game>> listAll() async {
    try {
      final dtos = await _localDao.listAll();
      return dtos.map((dto) => GameMapper.toEntity(dto)).toList();
    } catch (e) {
      throw Exception('Erro ao listar jogos: $e');
    }
  }

  @override
  Future<Game> update(Game game) async {
    try {
      final dto = GameMapper.toDto(game);
      final currentList = await _localDao.listAll();
      final index = currentList.indexWhere((e) => e.id == game.id);
      if (index >= 0) {
        currentList[index] = dto;
      } else {
        currentList.add(dto);
      }
      await _localDao.upsertAll(currentList);
      return game;
    } catch (e) {
      throw Exception('Erro ao atualizar jogo: $e');
    }
  }

  @override
  Future<void> sync() async {
    try {
      // Sincronização local apenas - sem servidor
      // Mantém compatibilidade com a interface
    } catch (e) {
      throw Exception('Erro ao sincronizar jogos: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await _localDao.clear();
    } catch (e) {
      throw Exception('Erro ao limpar cache de jogos: $e');
    }
  }

  @override
  Future<List<Game>> findByGenre(String genre) async {
    try {
      final dtos = await _localDao.listAll();
      final filtered = dtos.where((dto) => dto.genre.toLowerCase() == genre.toLowerCase()).toList();
      return filtered.map((dto) => GameMapper.toEntity(dto)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar jogos por gênero: $e');
    }
  }

  @override
  Future<List<Game>> findPopular({int limit = 10}) async {
    try {
      final dtos = await _localDao.listAll();
      final sorted = List<dynamic>.from(dtos);
      sorted.sort((a, b) => (b.total_matches as int).compareTo(a.total_matches as int));
      final popular = sorted.take(limit).toList();
      return popular.map((dto) => GameMapper.toEntity(dto as dynamic)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar jogos populares: $e');
    }
  }
}
