import '../../domain/entities/game.dart';
import '../datasources/games_remote_datasource.dart';
import '../mappers/game_mapper.dart';

/// Repository for Games
///
/// Orquestra:
/// - Remote data source (Supabase)
/// - Local cache (futuro)
/// - Mapper (DTO ↔ Entity)
///
/// A UI consome apenas Entities, nunca DTOs.
class GamesRepository {
  final GamesRemoteDataSource _remoteDataSource;

  GamesRepository({GamesRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? GamesRemoteDataSource();

  /// Busca todos os jogos
  Future<List<Game>> getAllGames() async {
    try {
      final dtos = await _remoteDataSource.fetchAllGames();
      return GameMapper.toEntities(dtos);
    } catch (e) {
      // Log do erro
      print('❌ GamesRepository.getAllGames: $e');
      rethrow;
    }
  }

  /// Busca um jogo por ID
  Future<Game?> getGameById(String id) async {
    try {
      final dto = await _remoteDataSource.fetchGameById(id);
      if (dto == null) return null;
      return GameMapper.toEntity(dto);
    } catch (e) {
      print('❌ GamesRepository.getGameById: $e');
      rethrow;
    }
  }

  /// Cria um novo jogo
  Future<Game> createGame(Game game) async {
    try {
      final dto = GameMapper.toDto(game);
      final createdDto = await _remoteDataSource.createGame(dto);
      return GameMapper.toEntity(createdDto);
    } catch (e) {
      print('❌ GamesRepository.createGame: $e');
      rethrow;
    }
  }

  /// Atualiza um jogo
  Future<Game> updateGame(Game game) async {
    try {
      final dto = GameMapper.toDto(game);
      final updatedDto = await _remoteDataSource.updateGame(game.id, dto);
      return GameMapper.toEntity(updatedDto);
    } catch (e) {
      print('❌ GamesRepository.updateGame: $e');
      rethrow;
    }
  }

  /// Deleta um jogo
  Future<void> deleteGame(String id) async {
    try {
      await _remoteDataSource.deleteGame(id);
    } catch (e) {
      print('❌ GamesRepository.deleteGame: $e');
      rethrow;
    }
  }

  /// Busca jogos por gênero
  Future<List<Game>> getGamesByGenre(String genre) async {
    try {
      final dtos = await _remoteDataSource.fetchGamesByGenre(genre);
      return GameMapper.toEntities(dtos);
    } catch (e) {
      print('❌ GamesRepository.getGamesByGenre: $e');
      rethrow;
    }
  }

  /// Sincronização incremental
  /// Retorna jogos atualizados desde a última sync
  Future<List<Game>> syncGames(DateTime lastSyncTime) async {
    try {
      final dtos = await _remoteDataSource.fetchUpdatedGames(lastSyncTime);
      return GameMapper.toEntities(dtos);
    } catch (e) {
      print('❌ GamesRepository.syncGames: $e');
      rethrow;
    }
  }
}