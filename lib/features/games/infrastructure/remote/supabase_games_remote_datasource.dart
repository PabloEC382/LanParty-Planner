import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../dtos/game_dto.dart';
import '../../../../core/models/remote_page.dart';
import '../../../../services/supabase_service.dart';
import 'games_remote_api.dart';

// ignore_for_file: unnecessary_null_checks

/// Implementação concreta de [GamesRemoteApi] usando Supabase como backend remoto.
///
/// Esta classe é responsável por:
/// - Conectar ao Supabase e buscar dados da tabela 'games'
/// - Filtrar por data de atualização (last_sync) para sincronização incremental
/// - Implementar paginação para evitar timeout e economizar banda
/// - Converter rows do Supabase em DTOs estruturados
/// - Tratar erros de rede, autenticação e parsing de forma defensiva
///
/// ⚠️ Dicas práticas para evitar erros comuns:
/// - Garanta que o DTO e o Mapper aceitam múltiplos formatos vindos do backend (ex: id como int/string, datas como DateTime/String).
/// - Sempre adicione prints/logs (usando kDebugMode) nos métodos de fetch mostrando o conteúdo dos dados recebidos e convertidos.
/// - Envolva parsing de datas, conversão de tipos e chamadas externas em try/catch, logando o erro e retornando valores seguros.
/// - Não exponha segredos (keys) em prints/logs.
/// - Consulte os arquivos de debug do projeto para exemplos de logs e soluções de problemas reais.
class SupabaseGamesRemoteDatasource implements GamesRemoteApi {
  static const String _tableName = 'games';

  final SupabaseClient? _client;

  SupabaseGamesRemoteDatasource({SupabaseClient? client})
      : _client = client ?? SupabaseService.client;

  @override
  Future<RemotePage<GameDto>> fetchGames({
    DateTime? since,
    int limit = 500,
    int offset = 0,
  }) async {
    try {
      final client = _client;
      if (client == null) {
        if (kDebugMode) {
          developer.log(
            'SupabaseGamesRemoteDatasource: cliente Supabase não inicializado',
            name: 'SupabaseGamesRemoteDatasource',
          );
        }
        return RemotePage(items: []);
      }

      // Construir query com filtro opcional de data
      final baseQuery = client.from(_tableName).select();

      // Filtrar por data de atualização se fornecido (sincronização incremental)
      late final List<dynamic> rows;
      if (since != null) {
        final sinceDateStr = since.toIso8601String();
        rows = await baseQuery
            .gte('updated_at', sinceDateStr)
            .order('updated_at', ascending: false)
            .range(offset, offset + limit - 1);

        if (kDebugMode) {
          developer.log(
            'SupabaseGamesRemoteDatasource.fetchGames: filtrando desde $sinceDateStr, recebidos ${rows.length} registros',
            name: 'SupabaseGamesRemoteDatasource',
          );
        }
      } else {
        // Sem filtro de data
        rows = await baseQuery
            .order('updated_at', ascending: false)
            .range(offset, offset + limit - 1);

        if (kDebugMode) {
          developer.log(
            'SupabaseGamesRemoteDatasource.fetchGames: sem filtro de data, recebidos ${rows.length} registros',
            name: 'SupabaseGamesRemoteDatasource',
          );
        }
      }

      return _processGameRows(rows, limit, offset);
    } on PostgrestException catch (e) {
      // Erro de banco de dados (RLS, conexão, etc)
      if (kDebugMode) {
        developer.log(
          'Erro PostgreSQL ao buscar games: ${e.message}',
          name: 'SupabaseGamesRemoteDatasource',
          error: e,
        );
      }
      return RemotePage(items: []);
    } catch (e) {
      // Erro genérico (rede, parsing, etc)
      if (kDebugMode) {
        developer.log(
          'Erro desconhecido ao buscar games: $e',
          name: 'SupabaseGamesRemoteDatasource',
          error: e,
        );
      }
      return RemotePage(items: []);
    }
  }

  /// Processa as linhas retornadas do Supabase e as converte em DTOs.
  Future<RemotePage<GameDto>> _processGameRows(
    List<dynamic> rows,
    int limit,
    int offset,
  ) async {
    // Converter rows para DTOs
    final List<GameDto> games = [];
    for (final row in rows) {
      try {
        final dto = GameDto.fromMap(Map<String, dynamic>.from(row as Map));
        games.add(dto);
      } catch (e) {
        if (kDebugMode) {
          developer.log(
            'Erro ao converter game DTO: $e',
            name: 'SupabaseGamesRemoteDatasource',
            error: e,
          );
        }
        // Continuar processando outros registros em caso de erro em um deles
        continue;
      }
    }

    // Determinar se há próxima página baseado no tamanho da resposta
    final hasMore = rows.length == limit;
    final nextOffset = hasMore ? offset + limit : null;

    if (kDebugMode) {
      developer.log(
        'SupabaseGamesRemoteDatasource: convertidos ${games.length} games, hasMore=$hasMore',
        name: 'SupabaseGamesRemoteDatasource',
      );
    }

    return RemotePage<GameDto>(
      items: games,
      next: hasMore ? nextOffset.toString() : null,
    );
  }

  @override
  Future<int> upsertGames(List<GameDto> dtos) async {
    try {
      final client = _client;
      if (client == null) {
        if (kDebugMode) {
          developer.log(
            'SupabaseGamesRemoteDatasource.upsertGames: cliente Supabase não inicializado',
            name: 'SupabaseGamesRemoteDatasource',
          );
        }
        return 0;
      }

      if (dtos.isEmpty) {
        if (kDebugMode) {
          developer.log(
            'SupabaseGamesRemoteDatasource.upsertGames: nenhum item para upsert',
            name: 'SupabaseGamesRemoteDatasource',
          );
        }
        return 0;
      }

      // Comentário: Converter DTOs para mapas para envio ao Supabase
      final maps = dtos.map((dto) => dto.toMap()).toList();

      if (kDebugMode) {
        developer.log(
          'SupabaseGamesRemoteDatasource.upsertGames: enviando ${dtos.length} items ao Supabase',
          name: 'SupabaseGamesRemoteDatasource',
        );
      }

      // Comentário: Usar upsert para insert-or-update
      // Isto requer que a tabela tenha unique constraints no campo 'id'
      final response = await client.from(_tableName).upsert(
        maps,
        onConflict: 'id', // Assume que 'id' é unique
      );

      if (kDebugMode) {
        developer.log(
          'SupabaseGamesRemoteDatasource.upsertGames: upsert response length = ${response.length}',
          name: 'SupabaseGamesRemoteDatasource',
        );
      }

      // Retorna quantidade de linhas processadas (melhor esforço)
      return response.length;
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro ao fazer upsert de games: $e',
          name: 'SupabaseGamesRemoteDatasource',
          error: e,
        );
      }
      return 0;
    }
  }

  @override
  Future<GameDto> createGame(GameDto dto) async {
    try {
      final client = _client;
      if (client == null) {
        if (kDebugMode) {
          developer.log(
            'SupabaseGamesRemoteDatasource.createGame: cliente Supabase não inicializado',
            name: 'SupabaseGamesRemoteDatasource',
          );
        }
        throw Exception('Supabase client not initialized');
      }

      if (kDebugMode) {
        developer.log(
          'SupabaseGamesRemoteDatasource.createGame: criando novo game',
          name: 'SupabaseGamesRemoteDatasource',
        );
      }

      final response = await client.from(_tableName).insert([dto.toMap()]).select();
      
      if (response.isEmpty) {
        throw Exception('Create failed: no rows returned from Supabase');
      }
      
      if (kDebugMode) {
        developer.log(
          'SupabaseGamesRemoteDatasource.createGame: game criado com sucesso',
          name: 'SupabaseGamesRemoteDatasource',
        );
      }

      return GameDto.fromMap(response[0]);
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro ao criar game: $e',
          name: 'SupabaseGamesRemoteDatasource',
          error: e,
        );
      }
      rethrow;
    }
  }

  @override
  Future<GameDto> updateGame(String id, GameDto dto) async {
    try {
      final client = _client;
      if (client == null) {
        if (kDebugMode) {
          developer.log(
            'SupabaseGamesRemoteDatasource.updateGame: cliente Supabase não inicializado',
            name: 'SupabaseGamesRemoteDatasource',
          );
        }
        throw Exception('Supabase client not initialized');
      }

      if (kDebugMode) {
        developer.log(
          'SupabaseGamesRemoteDatasource.updateGame: atualizando game $id',
          name: 'SupabaseGamesRemoteDatasource',
        );
      }

      final response = await client
          .from(_tableName)
          .update(dto.toMap())
          .eq('id', id)
          .select();
      
      if (response.isEmpty) {
        throw Exception('Update failed: no rows returned from Supabase');
      }
      
      if (kDebugMode) {
        developer.log(
          'SupabaseGamesRemoteDatasource.updateGame: game $id atualizado com sucesso',
          name: 'SupabaseGamesRemoteDatasource',
        );
      }

      return GameDto.fromMap(response[0]);
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro ao atualizar game: $e',
          name: 'SupabaseGamesRemoteDatasource',
          error: e,
        );
      }
      rethrow;
    }
  }

  @override
  Future<void> deleteGame(String id) async {
    try {
      final client = _client;
      if (client == null) {
        if (kDebugMode) {
          developer.log(
            'SupabaseGamesRemoteDatasource.deleteGame: cliente Supabase não inicializado',
            name: 'SupabaseGamesRemoteDatasource',
          );
        }
        throw Exception('Supabase client not initialized');
      }

      if (kDebugMode) {
        developer.log(
          'SupabaseGamesRemoteDatasource.deleteGame: deletando game id=$id (type=${id.runtimeType})',
          name: 'SupabaseGamesRemoteDatasource',
        );
      }

      final response = await client.from(_tableName).delete().eq('id', id);
      
      if (kDebugMode) {
        developer.log(
          'SupabaseGamesRemoteDatasource.deleteGame: resposta=$response',
          name: 'SupabaseGamesRemoteDatasource',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro ao deletar game: $e',
          name: 'SupabaseGamesRemoteDatasource',
          error: e,
        );
      }
      rethrow;
    }
  }
}

/*
// Exemplo de uso:
final remote = SupabaseGamesRemoteDatasource();
final page = await remote.fetchGames(limit: 500);
if (page.isNotEmpty) {
  print('Recebidos ${page.length} games do Supabase');
}

// Integração com DAO local e Repository:
final dao = GamesLocalDaoSharedPrefs();
final remoteApi = SupabaseGamesRemoteDatasource();
final repo = GamesRepositoryImpl(remoteApi: remoteApi, localDao: dao);
final lista = await repo.listAll();

// Dica: implemente sincronização em background usando isolates ou WorkManager.
// Para testes, crie um mock que retorna dados fixos.

// Checklist de erros comuns e como evitar:
// - Erro de conversão de tipos (ex: id como string): ajuste o fromMap do DTO para aceitar múltiplos formatos.
// - Falha ao atualizar UI após sync: verifique se o widget está mounted antes de chamar setState.
// - Dados não aparecem após sync: adicione prints/logs para inspecionar o conteúdo do cache e o fluxo de conversão.
// - Problemas com Supabase (RLS, inicialização): consulte supabase_rls_remediation.md e supabase_init_debug_prompt.md.
// - Erro de conexão: implemente exponential backoff e retry (máx 3 tentativas com delay crescente).

// Exemplo de logs esperados:
// SupabaseGamesRemoteDatasource.fetchGames: filtrando desde 2024-01-01T00:00:00.000Z
// SupabaseGamesRemoteDatasource.fetchGames: recebidos 3 registros
// SupabaseGamesRemoteDatasource.fetchGames: convertidos 3 games, hasMore=false

// Referências úteis:
// - games_cache_debug_prompt.md
// - supabase_init_debug_prompt.md
// - supabase_rls_remediation.md
*/
