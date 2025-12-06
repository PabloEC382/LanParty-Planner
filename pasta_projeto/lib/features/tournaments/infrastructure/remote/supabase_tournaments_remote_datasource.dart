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
}
