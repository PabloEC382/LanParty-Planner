import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/game.dart';
import '../../domain/repositories/games_repository.dart';
import '../mappers/game_mapper.dart';
import '../local/games_local_dao_shared_prefs.dart';
import '../remote/games_remote_api.dart';

/// Implementação concreta do [GamesRepository] usando estratégia de cache local com sincronização remota.
///
/// Esta classe combina:
/// - **Remote API**: sincronização com Supabase para dados atualizados
/// - **Local DAO**: cache local em SharedPreferences para offline-first
/// - **Smart Sync**: sincronização incremental baseada em timestamps
///
/// A estratégia de sincronização:
/// 1. Carregar dados do cache local (rápido, offline-ready)
/// 2. Em background, sincronizar com servidor (dados novos/atualizados)
/// 3. Atualizar cache local com novos dados
/// 4. Atualizar timestamp de last sync para próxima sincronização
///
/// ⚠️ Dicas práticas para evitar erros comuns:
/// - Sempre verifique se o widget está mounted antes de chamar setState em métodos assíncronos.
/// - Adicione prints/logs (usando kDebugMode) nos métodos de sync, cache e conversão para facilitar o diagnóstico.
/// - Use tratamento defensivo em parsing de datas e conversão de tipos.
/// - Consulte os arquivos de debug do projeto para exemplos de logs e soluções de problemas reais.
class GamesRepositoryImpl implements GamesRepository {
  static const String _lastSyncKeyV1 = 'games_last_sync_v1';

  final GamesRemoteApi _remoteApi;
  final GamesLocalDaoSharedPrefs _localDao;
  late final Future<SharedPreferences> _prefs;

  GamesRepositoryImpl({
    required GamesRemoteApi remoteApi,
    required GamesLocalDaoSharedPrefs localDao,
  })  : _remoteApi = remoteApi,
        _localDao = localDao {
    _prefs = SharedPreferences.getInstance();
  }

  /// Carrega games do cache local (resposta rápida para UI).
  /// 
  /// Este método retorna dados armazenados localmente sem acessar a rede,
  /// permitindo exibição instantânea na UI. Use em paralelo com [syncFromServer]
  /// para manter dados atualizados.
  /// 
  /// Boas práticas:
  /// - Sempre chame este método na inicialização da UI para melhor UX.
  /// - Se o cache estiver vazio, considere mostrar um loading indicator.
  /// - Use em combinação com FutureBuilder para melhor controle de estado.
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

  /// Sincroniza games do servidor Supabase de forma incremental.
  /// 
  /// Este método:
  /// 1. Lê o timestamp da última sincronização (stored_sync)
  /// 2. Busca apenas registros atualizados desde então
  /// 3. Faz upsert (insert ou update) no cache local
  /// 4. Atualiza o timestamp de última sincronização
  /// 5. Retorna quantos registros foram sincronizados
  /// 
  /// Boas práticas:
  /// - Chame em background após carregar dados do cache (não bloqueia UI).
  /// - Use debounce se chamado com alta frequência (ex: lista scrollavel).
  /// - Trate erros graciosamente, retornando 0 em caso de falha de rede.
  /// - Verifique kDebugMode antes de usar prints (não há overhead em production).
  @override
  Future<int> syncFromServer() async {
    try {
      if (kDebugMode) {
        developer.log(
          'GamesRepositoryImpl.syncFromServer: iniciando sincronização',
          name: 'GamesRepositoryImpl',
        );
      }

      // Obter timestamp da última sincronização
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
          // Continuar sem filtro de data em caso de erro
        }
      }

      // Buscar dados do servidor
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

      // Fazer upsert dos DTOs no cache local
      await _localDao.upsertAll(page.items);

      if (kDebugMode) {
        developer.log(
          'GamesRepositoryImpl.syncFromServer: ${page.items.length} games sincronizados',
          name: 'GamesRepositoryImpl',
        );
      }

      // Atualizar timestamp de última sincronização
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

  /// Lista todos os games disponíveis no cache.
  /// 
  /// Sempre chame [syncFromServer] antes deste método para garantir dados atualizados.
  /// 
  /// Boas práticas:
  /// - Use em combinação com [loadFromCache] para melhor UX.
  /// - Para grandes volumes, considere adicionar paginação na UI.
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

  /// Retorna apenas games marcados como destacados/featured.
  /// 
  /// Boas práticas:
  /// - Assegure-se de que a entidade Game possui um campo `featured` ou similar.
  /// - Use para exibir seções especiais na UI (ex: "Jogos em Destaque").
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
      // Filtrar por featured - ajuste conforme a estrutura da entidade
      final featured = dtos.where((dto) {
        // TODO: Adicionar campo featured na entidade se necessário
        // Por enquanto, retornar jogos com rating alto como "featured"
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

  /// Busca um game específico por ID no cache.
  /// 
  /// Boas práticas:
  /// - Verifique se o retorno é null antes de usar em UI.
  /// - Para buscas que necessitam de dados remotos, considere chamar syncFromServer primeiro.
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

  /// Computar o timestamp mais recente dos DTOs retornados.
  /// Usado para atualizar o marcador de last_sync.
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
}

/*
// Exemplo de uso:
final remoteApi = SupabaseGamesRemoteDatasource();
final dao = GamesLocalDaoSharedPrefs();
final repo = GamesRepositoryImpl(remoteApi: remoteApi, localDao: dao);

// Fluxo recomendado na UI:
// 1. Carregar do cache para resposta rápida
final cachedGames = await repo.loadFromCache();

// 2. Em background, sincronizar com servidor
unawaited(
  repo.syncFromServer().then((count) {
    if (count > 0) {
      // Atualizar UI com novos dados
      setState(() {}); // if mounted
    }
  }),
);

// 3. Listar todos os games (do cache, já sincronizado)
final allGames = await repo.listAll();

// Dica: combine com streams ou StateNotifier para melhor gerenciamento de estado.

// Checklist de erros comuns e como evitar:
// - Erro de conversão de tipos (ex: id como string): ajuste o fromMap do DTO para aceitar múltiplos formatos.
// - Falha ao atualizar UI após sync: verifique se o widget está mounted antes de chamar setState.
// - Dados não aparecem após sync: adicione prints/logs para inspecionar o conteúdo do cache e o fluxo de conversão.
// - Problemas com Supabase (RLS, inicialização): consulte supabase_rls_remediation.md e supabase_init_debug_prompt.md.

// Exemplo de logs esperados:
// GamesRepositoryImpl.loadFromCache: carregando do cache
// GamesRepositoryImpl.loadFromCache: carregados 5 games do cache
// GamesRepositoryImpl.syncFromServer: iniciando sincronização
// GamesRepositoryImpl.syncFromServer: última sincronização em 2024-12-01T10:00:00.000Z
// GamesRepositoryImpl.syncFromServer: 2 games sincronizados
// GamesRepositoryImpl.syncFromServer: last_sync atualizado para 2024-12-06T15:30:00.000Z
// GamesRepositoryImpl.listAll: listando todos os games
// GamesRepositoryImpl.listAll: 7 games retornados

// Referências úteis:
// - games_cache_debug_prompt.md
// - supabase_init_debug_prompt.md
// - supabase_rls_remediation.md
*/
