import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../dtos/game_dto.dart';
import '../../../../core/models/remote_page.dart';
import '../../../../services/supabase_service.dart';
import 'games_remote_api.dart';

class SupabaseGamesRemoteDatasource implements GamesRemoteApi {
  static const String _tableName = 'games';

  final SupabaseClient? _providedClient;

  SupabaseGamesRemoteDatasource({SupabaseClient? client})
    : _providedClient = client;

  SupabaseClient get _client => _providedClient ?? SupabaseService.client;

  @override
  Future<RemotePage<GameDto>> fetchGames({
    DateTime? since,
    int limit = 500,
    int offset = 0,
  }) async {
    try {
      final baseQuery = _client.from(_tableName).select();

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
      if (kDebugMode) {
        developer.log(
          'Erro PostgreSQL ao buscar games: ${e.message}',
          name: 'SupabaseGamesRemoteDatasource',
          error: e,
        );
      }
      return RemotePage(items: []);
    } catch (e) {
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
        continue;
      }
    }

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
      if (dtos.isEmpty) {
        if (kDebugMode) {
          developer.log(
            'SupabaseGamesRemoteDatasource.upsertGames: nenhum item para upsert',
            name: 'SupabaseGamesRemoteDatasource',
          );
        }
        return 0;
      }

      final maps = dtos.map((dto) => dto.toMap()).toList();

      if (kDebugMode) {
        developer.log(
          'SupabaseGamesRemoteDatasource.upsertGames: enviando ${dtos.length} items ao Supabase',
          name: 'SupabaseGamesRemoteDatasource',
        );
      }

      final response = await _client
          .from(_tableName)
          .upsert(maps, onConflict: 'id');

      if (kDebugMode) {
        developer.log(
          'SupabaseGamesRemoteDatasource.upsertGames: upsert response length = ${response.length}',
          name: 'SupabaseGamesRemoteDatasource',
        );
      }

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
      if (kDebugMode) {
        developer.log(
          'SupabaseGamesRemoteDatasource.createGame: criando novo game',
          name: 'SupabaseGamesRemoteDatasource',
        );
      }

      final response = await _client.from(_tableName).insert([
        dto.toMap(),
      ]).select();

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
      if (kDebugMode) {
        developer.log(
          'SupabaseGamesRemoteDatasource.updateGame: atualizando game $id',
          name: 'SupabaseGamesRemoteDatasource',
        );
      }

      final response = await _client
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
      if (kDebugMode) {
        developer.log(
          'SupabaseGamesRemoteDatasource.deleteGame: deletando game id=$id (type=${id.runtimeType})',
          name: 'SupabaseGamesRemoteDatasource',
        );
      }

      final response = await _client.from(_tableName).delete().eq('id', id);

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
