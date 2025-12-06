import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../dtos/event_dto.dart';
import '../../../../core/models/remote_page.dart';
import '../../../../services/supabase_service.dart';
import 'events_remote_api.dart';

/// Implementação concreta de [EventsRemoteApi] usando Supabase como backend remoto.
class SupabaseEventsRemoteDatasource implements EventsRemoteApi {
  static const String _tableName = 'events';
  final SupabaseClient? _client;

  SupabaseEventsRemoteDatasource({SupabaseClient? client})
      : _client = client ?? SupabaseService.client;

  @override
  Future<RemotePage<EventDto>> fetchEvents({
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
            'SupabaseEventsRemoteDatasource.fetchEvents: filtrando desde $sinceDateStr, recebidos ${rows.length} registros',
            name: 'SupabaseEventsRemoteDatasource',
          );
        }
      } else {
        rows = await baseQuery
            .order('updated_at', ascending: false)
            .range(offset, offset + limit - 1);

        if (kDebugMode) {
          developer.log(
            'SupabaseEventsRemoteDatasource.fetchEvents: sem filtro de data, recebidos ${rows.length} registros',
            name: 'SupabaseEventsRemoteDatasource',
          );
        }
      }

      return _processEventRows(rows, limit, offset);
    } on PostgrestException catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro PostgreSQL ao buscar events: ${e.message}',
          name: 'SupabaseEventsRemoteDatasource',
          error: e,
        );
      }
      return RemotePage(items: []);
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro desconhecido ao buscar events: $e',
          name: 'SupabaseEventsRemoteDatasource',
          error: e,
        );
      }
      return RemotePage(items: []);
    }
  }

  Future<RemotePage<EventDto>> _processEventRows(
    List<dynamic> rows,
    int limit,
    int offset,
  ) async {
    final List<EventDto> events = [];
    for (final row in rows) {
      try {
        final dto = EventDto.fromMap(Map<String, dynamic>.from(row as Map));
        events.add(dto);
      } catch (e) {
        if (kDebugMode) {
          developer.log(
            'Erro ao converter event DTO: $e',
            name: 'SupabaseEventsRemoteDatasource',
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
        'SupabaseEventsRemoteDatasource: convertidos ${events.length} events, hasMore=$hasMore',
        name: 'SupabaseEventsRemoteDatasource',
      );
    }

    return RemotePage<EventDto>(
      items: events,
      next: hasMore ? nextOffset.toString() : null,
    );
  }
}
