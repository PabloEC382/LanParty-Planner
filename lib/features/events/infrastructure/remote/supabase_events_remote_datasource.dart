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
  final SupabaseClient? _providedClient;

  SupabaseEventsRemoteDatasource({SupabaseClient? client})
      : _providedClient = client;

  SupabaseClient get _client => _providedClient ?? SupabaseService.client;

  @override
  Future<RemotePage<EventDto>> fetchEvents({
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
    } on StateError catch (e) {
      // Supabase não foi inicializado - propagar o erro
      if (kDebugMode) {
        developer.log(
          'Supabase não inicializado ao buscar events: ${e.message}',
          name: 'SupabaseEventsRemoteDatasource',
          error: e,
        );
      }
      rethrow;
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

  @override
  Future<int> upsertEvents(List<EventDto> dtos) async {
    try {
      if (dtos.isEmpty) {
        if (kDebugMode) {
          developer.log(
            'SupabaseEventsRemoteDatasource.upsertEvents: nenhum item para upsert',
            name: 'SupabaseEventsRemoteDatasource',
          );
        }
        return 0;
      }

      // Comentário: Converter DTOs para mapas para envio ao Supabase
      final maps = dtos.map((dto) => dto.toMap()).toList();

      if (kDebugMode) {
        developer.log(
          'SupabaseEventsRemoteDatasource.upsertEvents: enviando ${dtos.length} items ao Supabase',
          name: 'SupabaseEventsRemoteDatasource',
        );
      }

      // Comentário: Usar upsert para insert-or-update
      final response = await _client.from(_tableName).upsert(
        maps,
        onConflict: 'id',
      );

      if (kDebugMode) {
        developer.log(
          'SupabaseEventsRemoteDatasource.upsertEvents: upsert response length = ${response.length}',
          name: 'SupabaseEventsRemoteDatasource',
        );
      }

      return response.length;
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro ao fazer upsert de events: $e',
          name: 'SupabaseEventsRemoteDatasource',
          error: e,
        );
      }
      return 0;
    }
  }

  @override
  Future<EventDto> createEvent(EventDto dto) async {
    try {
      if (kDebugMode) {
        developer.log(
          'SupabaseEventsRemoteDatasource.createEvent: criando novo event',
          name: 'SupabaseEventsRemoteDatasource',
        );
      }

      final response = await _client.from(_tableName).insert([dto.toMap()]).select();
      if (response.isEmpty) {
        throw Exception('Create failed: no rows returned from Supabase');
      }
      return EventDto.fromMap(response[0]);
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro ao criar event: $e',
          name: 'SupabaseEventsRemoteDatasource',
          error: e,
        );
      }
      rethrow;
    }
  }

  @override
  Future<EventDto> updateEvent(String id, EventDto dto) async {
    try {
      if (kDebugMode) {
        developer.log(
          'SupabaseEventsRemoteDatasource.updateEvent: atualizando event $id',
          name: 'SupabaseEventsRemoteDatasource',
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

      return EventDto.fromMap(response[0]);
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro ao atualizar event: $e',
          name: 'SupabaseEventsRemoteDatasource',
          error: e,
        );
      }
      rethrow;
    }
  }

  @override
  Future<void> deleteEvent(String id) async {
    try {
      if (kDebugMode) {
        developer.log(
          'SupabaseEventsRemoteDatasource.deleteEvent: deletando event id=$id (type=${id.runtimeType})',
          name: 'SupabaseEventsRemoteDatasource',
        );
      }

      final response = await _client.from(_tableName).delete().eq('id', id);
      
      if (kDebugMode) {
        developer.log(
          'SupabaseEventsRemoteDatasource.deleteEvent: resposta=$response',
          name: 'SupabaseEventsRemoteDatasource',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro ao deletar event: $e',
          name: 'SupabaseEventsRemoteDatasource',
          error: e,
        );
      }
      rethrow;
    }
  }
}
