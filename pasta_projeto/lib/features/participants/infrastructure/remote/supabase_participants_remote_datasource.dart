import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../dtos/participant_dto.dart';
import '../../../../core/models/remote_page.dart';
import '../../../../services/supabase_service.dart';
import 'participants_remote_api.dart';

/// Implementação concreta de [ParticipantsRemoteApi] usando Supabase como backend remoto.
class SupabaseParticipantsRemoteDatasource implements ParticipantsRemoteApi {
  static const String _tableName = 'participants';
  final SupabaseClient? _client;

  SupabaseParticipantsRemoteDatasource({SupabaseClient? client})
      : _client = client ?? SupabaseService.client;

  @override
  Future<RemotePage<ParticipantDto>> fetchParticipants({
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
            'SupabaseParticipantsRemoteDatasource.fetchParticipants: filtrando desde $sinceDateStr, recebidos ${rows.length} registros',
            name: 'SupabaseParticipantsRemoteDatasource',
          );
        }
      } else {
        rows = await baseQuery
            .order('updated_at', ascending: false)
            .range(offset, offset + limit - 1);

        if (kDebugMode) {
          developer.log(
            'SupabaseParticipantsRemoteDatasource.fetchParticipants: sem filtro de data, recebidos ${rows.length} registros',
            name: 'SupabaseParticipantsRemoteDatasource',
          );
        }
      }

      return _processParticipantRows(rows, limit, offset);
    } on PostgrestException catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro PostgreSQL ao buscar participants: ${e.message}',
          name: 'SupabaseParticipantsRemoteDatasource',
          error: e,
        );
      }
      return RemotePage(items: []);
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro desconhecido ao buscar participants: $e',
          name: 'SupabaseParticipantsRemoteDatasource',
          error: e,
        );
      }
      return RemotePage(items: []);
    }
  }

  Future<RemotePage<ParticipantDto>> _processParticipantRows(
    List<dynamic> rows,
    int limit,
    int offset,
  ) async {
    final List<ParticipantDto> participants = [];
    for (final row in rows) {
      try {
        final dto = ParticipantDto.fromMap(Map<String, dynamic>.from(row as Map));
        participants.add(dto);
      } catch (e) {
        if (kDebugMode) {
          developer.log(
            'Erro ao converter participant DTO: $e',
            name: 'SupabaseParticipantsRemoteDatasource',
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
        'SupabaseParticipantsRemoteDatasource: convertidos ${participants.length} participants, hasMore=$hasMore',
        name: 'SupabaseParticipantsRemoteDatasource',
      );
    }

    return RemotePage<ParticipantDto>(
      items: participants,
      next: hasMore ? nextOffset.toString() : null,
    );
  }

  @override
  Future<int> upsertParticipants(List<ParticipantDto> dtos) async {
    try {
      final client = _client;
      if (client == null) {
        if (kDebugMode) {
          developer.log(
            'SupabaseParticipantsRemoteDatasource.upsertParticipants: cliente Supabase não inicializado',
            name: 'SupabaseParticipantsRemoteDatasource',
          );
        }
        return 0;
      }

      if (dtos.isEmpty) {
        if (kDebugMode) {
          developer.log(
            'SupabaseParticipantsRemoteDatasource.upsertParticipants: nenhum item para upsert',
            name: 'SupabaseParticipantsRemoteDatasource',
          );
        }
        return 0;
      }

      // Comentário: Converter DTOs para mapas para envio ao Supabase
      final maps = dtos.map((dto) => dto.toMap()).toList();

      if (kDebugMode) {
        developer.log(
          'SupabaseParticipantsRemoteDatasource.upsertParticipants: enviando ${dtos.length} items ao Supabase',
          name: 'SupabaseParticipantsRemoteDatasource',
        );
      }

      // Comentário: Usar upsert para insert-or-update
      final response = await client.from('participants').upsert(
        maps,
        onConflict: 'id',
      );

      if (kDebugMode) {
        developer.log(
          'SupabaseParticipantsRemoteDatasource.upsertParticipants: upsert response length = ${response.length}',
          name: 'SupabaseParticipantsRemoteDatasource',
        );
      }

      return response.length;
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro ao fazer upsert de participants: $e',
          name: 'SupabaseParticipantsRemoteDatasource',
          error: e,
        );
      }
      return 0;
    }
  }

  @override
  Future<ParticipantDto> createParticipant(ParticipantDto dto) async {
    try {
      final client = _client;
      if (client == null) {
        throw Exception('Supabase client not initialized');
      }

      if (kDebugMode) {
        developer.log(
          'SupabaseParticipantsRemoteDatasource.createParticipant: criando novo participant',
          name: 'SupabaseParticipantsRemoteDatasource',
        );
      }

      final response = await client.from('participants').insert([dto.toMap()]);
      return ParticipantDto.fromMap(response[0] as Map<String, dynamic>);
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro ao criar participant: $e',
          name: 'SupabaseParticipantsRemoteDatasource',
          error: e,
        );
      }
      rethrow;
    }
  }

  @override
  Future<ParticipantDto> updateParticipant(String id, ParticipantDto dto) async {
    try {
      final client = _client;
      if (client == null) {
        throw Exception('Supabase client not initialized');
      }

      if (kDebugMode) {
        developer.log(
          'SupabaseParticipantsRemoteDatasource.updateParticipant: atualizando participant $id',
          name: 'SupabaseParticipantsRemoteDatasource',
        );
      }

      final response = await client
          .from('participants')
          .update(dto.toMap())
          .eq('id', id);

      return ParticipantDto.fromMap(response[0] as Map<String, dynamic>);
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro ao atualizar participant: $e',
          name: 'SupabaseParticipantsRemoteDatasource',
          error: e,
        );
      }
      rethrow;
    }
  }

  @override
  Future<void> deleteParticipant(String id) async {
    try {
      final client = _client;
      if (client == null) {
        throw Exception('Supabase client not initialized');
      }

      if (kDebugMode) {
        developer.log(
          'SupabaseParticipantsRemoteDatasource.deleteParticipant: deletando participant $id',
          name: 'SupabaseParticipantsRemoteDatasource',
        );
      }

      await client.from('participants').delete().eq('id', id);
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro ao deletar participant: $e',
          name: 'SupabaseParticipantsRemoteDatasource',
          error: e,
        );
      }
      rethrow;
    }
  }
}
