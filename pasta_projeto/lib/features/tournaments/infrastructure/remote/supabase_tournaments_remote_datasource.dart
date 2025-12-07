import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../dtos/tournament_dto.dart';
import '../../../../core/models/remote_page.dart';
import '../../../../services/supabase_service.dart';
import 'tournaments_remote_api.dart';

/// Implementação concreta de [TournamentsRemoteApi] usando Supabase como backend remoto.
class SupabaseTournamentsRemoteDatasource implements TournamentsRemoteApi {
  static const String _tableName = 'tournaments';
  final SupabaseClient? _client;

  SupabaseTournamentsRemoteDatasource({SupabaseClient? client})
      : _client = client ?? SupabaseService.client;

  @override
  Future<RemotePage<TournamentDto>> fetchTournaments({
    DateTime? since,
    int limit = 500,
    int offset = 0,
  }) async {
    try {
      final client = _client;
      if (client == null) {
        return RemotePage(items: []);
      }

      final baseQuery = client.from(_tableName).select();

      late final List<dynamic> rows;
      if (since != null) {
        final sinceDateStr = since.toIso8601String();
        rows = await baseQuery
            .gte('updated_at', sinceDateStr)
            .order('updated_at', ascending: false)
            .range(offset, offset + limit - 1);

        if (kDebugMode) {
          developer.log(
            'SupabaseTournamentsRemoteDatasource.fetchTournaments: filtrando desde $sinceDateStr, recebidos ${rows.length} registros',
            name: 'SupabaseTournamentsRemoteDatasource',
          );
        }
      } else {
        rows = await baseQuery
            .order('updated_at', ascending: false)
            .range(offset, offset + limit - 1);

        if (kDebugMode) {
          developer.log(
            'SupabaseTournamentsRemoteDatasource.fetchTournaments: sem filtro de data, recebidos ${rows.length} registros',
            name: 'SupabaseTournamentsRemoteDatasource',
          );
        }
      }

      return _processTournamentRows(rows, limit, offset);
    } on PostgrestException catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro PostgreSQL ao buscar tournaments: ${e.message}',
          name: 'SupabaseTournamentsRemoteDatasource',
          error: e,
        );
      }
      return RemotePage(items: []);
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro desconhecido ao buscar tournaments: $e',
          name: 'SupabaseTournamentsRemoteDatasource',
          error: e,
        );
      }
      return RemotePage(items: []);
    }
  }

  Future<RemotePage<TournamentDto>> _processTournamentRows(
    List<dynamic> rows,
    int limit,
    int offset,
  ) async {
    final List<TournamentDto> tournaments = [];
    for (final row in rows) {
      try {
        final dto = TournamentDto.fromMap(Map<String, dynamic>.from(row as Map));
        tournaments.add(dto);
      } catch (e) {
        if (kDebugMode) {
          developer.log(
            'Erro ao converter tournament DTO: $e',
            name: 'SupabaseTournamentsRemoteDatasource',
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
        'SupabaseTournamentsRemoteDatasource: convertidos ${tournaments.length} tournaments, hasMore=$hasMore',
        name: 'SupabaseTournamentsRemoteDatasource',
      );
    }

    return RemotePage<TournamentDto>(
      items: tournaments,
      next: hasMore ? nextOffset.toString() : null,
    );
  }

  @override
  Future<int> upsertTournaments(List<TournamentDto> dtos) async {
    try {
      final client = _client;
      if (client == null) {
        if (kDebugMode) {
          developer.log(
            'SupabaseTournamentsRemoteDatasource.upsertTournaments: cliente Supabase não inicializado',
            name: 'SupabaseTournamentsRemoteDatasource',
          );
        }
        return 0;
      }

      if (dtos.isEmpty) {
        if (kDebugMode) {
          developer.log(
            'SupabaseTournamentsRemoteDatasource.upsertTournaments: nenhum item para upsert',
            name: 'SupabaseTournamentsRemoteDatasource',
          );
        }
        return 0;
      }

      // Comentário: Converter DTOs para mapas para envio ao Supabase
      final maps = dtos.map((dto) => dto.toMap()).toList();

      if (kDebugMode) {
        developer.log(
          'SupabaseTournamentsRemoteDatasource.upsertTournaments: enviando ${dtos.length} items ao Supabase',
          name: 'SupabaseTournamentsRemoteDatasource',
        );
      }

      // Comentário: Usar upsert para insert-or-update
      final response = await client.from('tournaments').upsert(
        maps,
        onConflict: 'id',
      );

      if (kDebugMode) {
        developer.log(
          'SupabaseTournamentsRemoteDatasource.upsertTournaments: upsert response length = ${response.length}',
          name: 'SupabaseTournamentsRemoteDatasource',
        );
      }

      return response.length;
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro ao fazer upsert de tournaments: $e',
          name: 'SupabaseTournamentsRemoteDatasource',
          error: e,
        );
      }
      return 0;
    }
  }

  @override
  Future<TournamentDto> createTournament(TournamentDto dto) async {
    try {
      final client = _client;
      if (client == null) {
        throw Exception('Supabase client not initialized');
      }

      if (kDebugMode) {
        developer.log(
          'SupabaseTournamentsRemoteDatasource.createTournament: criando novo tournament',
          name: 'SupabaseTournamentsRemoteDatasource',
        );
      }

      final response = await client.from('tournaments').insert([dto.toMap()]).select();
      if (response.isEmpty) {
        throw Exception('Create failed: no rows returned from Supabase');
      }
      return TournamentDto.fromMap(response[0]);
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro ao criar tournament: $e',
          name: 'SupabaseTournamentsRemoteDatasource',
          error: e,
        );
      }
      rethrow;
    }
  }

  @override
  Future<TournamentDto> updateTournament(String id, TournamentDto dto) async {
    try {
      final client = _client;
      if (client == null) {
        throw Exception('Supabase client not initialized');
      }

      if (kDebugMode) {
        developer.log(
          'SupabaseTournamentsRemoteDatasource.updateTournament: atualizando tournament $id',
          name: 'SupabaseTournamentsRemoteDatasource',
        );
      }

      final response = await client
          .from('tournaments')
          .update(dto.toMap())
          .eq('id', id)
          .select();

      if (response.isEmpty) {
        throw Exception('Update failed: no rows returned from Supabase');
      }

      return TournamentDto.fromMap(response[0]);
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro ao atualizar tournament: $e',
          name: 'SupabaseTournamentsRemoteDatasource',
          error: e,
        );
      }
      rethrow;
    }
  }

  @override
  Future<void> deleteTournament(String id) async {
    try {
      final client = _client;
      if (client == null) {
        throw Exception('Supabase client not initialized');
      }

      if (kDebugMode) {
        developer.log(
          'SupabaseTournamentsRemoteDatasource.deleteTournament: deletando tournament id=$id (type=${id.runtimeType})',
          name: 'SupabaseTournamentsRemoteDatasource',
        );
      }

      final response = await client.from('tournaments').delete().eq('id', id);
      if (kDebugMode) {
        developer.log(
          'SupabaseTournamentsRemoteDatasource.deleteTournament: resposta=$response',
          name: 'SupabaseTournamentsRemoteDatasource',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro ao deletar tournament: $e',
          name: 'SupabaseTournamentsRemoteDatasource',
          error: e,
        );
      }
      rethrow;
    }
  }
}
