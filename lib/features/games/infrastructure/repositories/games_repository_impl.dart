import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/game.dart';
import '../../domain/repositories/games_repository.dart';
import '../mappers/game_mapper.dart';
import '../local/games_local_dao_shared_prefs.dart';
import '../remote/games_remote_api.dart';

class GamesRepositoryImpl implements GamesRepository {
  static const String _lastSyncKeyV1 = 'games_last_sync_v1';

  final GamesRemoteApi _remoteApi;
  final GamesLocalDaoSharedPrefs _localDao;
  late final Future<SharedPreferences> _prefs;

  GamesRepositoryImpl({
    required GamesRemoteApi remoteApi,
    required GamesLocalDaoSharedPrefs localDao,
  }) : _remoteApi = remoteApi,
       _localDao = localDao {
    _prefs = SharedPreferences.getInstance();
  }

  /// Carrega games do cache local.
  @override
  Future<List<Game>> loadFromCache() async {
    try {
      if (kDebugMode) {
        developer.log(
          'GamesRepositoryImpl.loadFromCache: carregando do cache',
          name: 'GamesRepositoryImpl',
        );
      }

      final dtos = await _localDao.listAll();
      final games = dtos.map((dto) => GameMapper.toEntity(dto)).toList();

      if (kDebugMode) {
        developer.log(
          'GamesRepositoryImpl.loadFromCache: carregados ${games.length} games do cache',
          name: 'GamesRepositoryImpl',
        );
      }

      return games;
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro ao carregar cache de games: $e',
          name: 'GamesRepositoryImpl',
          error: e,
        );
      }
      return [];
    }
  }

  /// Sincroniza games do servidor Supabase.
  @override
  Future<int> syncFromServer() async {
    try {
      if (kDebugMode) {
        developer.log(
          'GamesRepositoryImpl.syncFromServer: iniciando sincronização (push então pull)',
          name: 'GamesRepositoryImpl',
        );
      }

      try {
        final localDtos = await _localDao.listAll();
        if (localDtos.isNotEmpty) {
          final pushed = await _remoteApi.upsertGames(localDtos);
          if (kDebugMode) {
            developer.log(
              'GamesRepositoryImpl.syncFromServer: pushed $pushed items ao remoto',
              name: 'GamesRepositoryImpl',
            );
          }
        }
      } catch (pushError) {
        if (kDebugMode) {
          developer.log(
            'GamesRepositoryImpl.syncFromServer: erro ao fazer push (continuando com pull): $pushError',
            name: 'GamesRepositoryImpl',
            error: pushError,
          );
        }
      }

      final prefs = await _prefs;
      final lastSyncIso = prefs.getString(_lastSyncKeyV1);

      DateTime? since;
      if (lastSyncIso != null && lastSyncIso.isNotEmpty) {
        try {
          since = DateTime.parse(lastSyncIso);

          if (kDebugMode) {
            developer.log(
              'GamesRepositoryImpl.syncFromServer: última sincronização em ${since.toIso8601String()}',
              name: 'GamesRepositoryImpl',
            );
          }
        } catch (e) {
          if (kDebugMode) {
            developer.log(
              'Erro ao parsear lastSync de games: $e',
              name: 'GamesRepositoryImpl',
              error: e,
            );
          }
        }
      }

      final page = await _remoteApi.fetchGames(since: since, limit: 500);

      if (page.isEmpty) {
        if (kDebugMode) {
          developer.log(
            'GamesRepositoryImpl.syncFromServer: nenhum novo game para sincronizar',
            name: 'GamesRepositoryImpl',
          );
        }
        return 0;
      }

      await _localDao.upsertAll(page.items);

      if (kDebugMode) {
        developer.log(
          'GamesRepositoryImpl.syncFromServer: ${page.items.length} games sincronizados',
          name: 'GamesRepositoryImpl',
        );
      }

      final newestUpdatedAt = _computeNewestUpdatedAt(page.items);
      await prefs.setString(_lastSyncKeyV1, newestUpdatedAt.toIso8601String());

      if (kDebugMode) {
        developer.log(
          'GamesRepositoryImpl.syncFromServer: last_sync atualizado para ${newestUpdatedAt.toIso8601String()}',
          name: 'GamesRepositoryImpl',
        );
      }

      return page.items.length;
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro ao sincronizar games: $e',
          name: 'GamesRepositoryImpl',
          error: e,
        );
      }
      return 0;
    }
  }

  /// Lista todos os games.
  @override
  Future<List<Game>> listAll() async {
    try {
      if (kDebugMode) {
        developer.log(
          'GamesRepositoryImpl.listAll: listando todos os games',
          name: 'GamesRepositoryImpl',
        );
      }

      final dtos = await _localDao.listAll();
      final games = dtos.map((dto) => GameMapper.toEntity(dto)).toList();

      if (kDebugMode) {
        developer.log(
          'GamesRepositoryImpl.listAll: ${games.length} games retornados',
          name: 'GamesRepositoryImpl',
        );
      }

      return games;
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro ao listar games: $e',
          name: 'GamesRepositoryImpl',
          error: e,
        );
      }
      return [];
    }
  }

  /// Retorna apenas games marcados como destacados.
  @override
  Future<List<Game>> listFeatured() async {
    try {
      if (kDebugMode) {
        developer.log(
          'GamesRepositoryImpl.listFeatured: listando games em destaque',
          name: 'GamesRepositoryImpl',
        );
      }

      final dtos = await _localDao.listAll();
      final featured = dtos.where((dto) {
        return dto.average_rating >= 4.5;
      }).toList();

      final games = featured.map((dto) => GameMapper.toEntity(dto)).toList();

      if (kDebugMode) {
        developer.log(
          'GamesRepositoryImpl.listFeatured: ${games.length} games em destaque retornados',
          name: 'GamesRepositoryImpl',
        );
      }

      return games;
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro ao listar games em destaque: $e',
          name: 'GamesRepositoryImpl',
          error: e,
        );
      }
      return [];
    }
  }

  /// Busca um game específico por ID.
  @override
  Future<Game?> getById(int id) async {
    try {
      if (kDebugMode) {
        developer.log(
          'GamesRepositoryImpl.getById: buscando game com id=$id',
          name: 'GamesRepositoryImpl',
        );
      }

      final dto = await _localDao.getById(id.toString());
      final game = dto != null ? GameMapper.toEntity(dto) : null;

      if (kDebugMode) {
        developer.log(
          'GamesRepositoryImpl.getById: game${game != null ? ' encontrado' : ' não encontrado'}',
          name: 'GamesRepositoryImpl',
        );
      }

      return game;
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro ao buscar game por id: $e',
          name: 'GamesRepositoryImpl',
          error: e,
        );
      }
      return null;
    }
  }

  /// Computar o timestamp mais recente dos DTOs.
  DateTime _computeNewestUpdatedAt(List<dynamic> items) {
    if (items.isEmpty) {
      return DateTime.now().toUtc();
    }

    DateTime newest = DateTime.parse(items[0].updated_at as String);
    for (final item in items) {
      try {
        final itemDate = DateTime.parse(item.updated_at as String);
        if (itemDate.isAfter(newest)) {
          newest = itemDate;
        }
      } catch (_) {}
    }

    return newest;
  }

  /// Cria um novo game no servidor e cache local.
  Future<Game> createGame(Game game) async {
    try {
      final dto = GameMapper.toDto(game);
      final createdDto = await _remoteApi.createGame(dto);
      await _localDao.upsertAll([createdDto]);

      if (kDebugMode) {
        developer.log(
          'GamesRepositoryImpl.createGame: game criado com sucesso: ${game.id}',
          name: 'GamesRepositoryImpl',
        );
      }

      return GameMapper.toEntity(createdDto);
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro ao criar game: $e',
          name: 'GamesRepositoryImpl',
          error: e,
        );
      }
      rethrow;
    }
  }

  /// Atualiza um game no servidor e cache local.
  Future<Game> updateGame(Game game) async {
    try {
      final dto = GameMapper.toDto(game);
      final updatedDto = await _remoteApi.updateGame(game.id, dto);
      await _localDao.upsertAll([updatedDto]);

      if (kDebugMode) {
        developer.log(
          'GamesRepositoryImpl.updateGame: game atualizado com sucesso: ${game.id}',
          name: 'GamesRepositoryImpl',
        );
      }

      return GameMapper.toEntity(updatedDto);
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro ao atualizar game: $e',
          name: 'GamesRepositoryImpl',
          error: e,
        );
      }
      rethrow;
    }
  }

  /// Deleta um game do servidor e cache local.
  Future<void> deleteGame(String id) async {
    try {
      await _remoteApi.deleteGame(id);
      // Remove do cache local
      final allGames = await _localDao.listAll();
      final filtered = allGames.where((dto) => dto.id != id).toList();
      await _localDao.clear();
      if (filtered.isNotEmpty) {
        await _localDao.upsertAll(filtered);
      }

      if (kDebugMode) {
        developer.log(
          'GamesRepositoryImpl.deleteGame: game deletado com sucesso: $id',
          name: 'GamesRepositoryImpl',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro ao deletar game: $e',
          name: 'GamesRepositoryImpl',
          error: e,
        );
      }
      rethrow;
    }
  }
}
