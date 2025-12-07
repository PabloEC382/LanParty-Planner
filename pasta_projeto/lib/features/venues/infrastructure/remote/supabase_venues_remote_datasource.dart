import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../dtos/venue_dto.dart';
import '../../../../core/models/remote_page.dart';
import '../../../../services/supabase_service.dart';
import 'venues_remote_api.dart';

/// Implementação concreta de [VenuesRemoteApi] usando Supabase como backend remoto.
class SupabaseVenuesRemoteDatasource implements VenuesRemoteApi {
  static const String _tableName = 'venues';
  final SupabaseClient? _client;

  SupabaseVenuesRemoteDatasource({SupabaseClient? client})
      : _client = client ?? SupabaseService.client;

  @override
  Future<RemotePage<VenueDto>> fetchVenues({
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
            'SupabaseVenuesRemoteDatasource.fetchVenues: filtrando desde $sinceDateStr, recebidos ${rows.length} registros',
            name: 'SupabaseVenuesRemoteDatasource',
          );
        }
      } else {
        rows = await baseQuery
            .order('updated_at', ascending: false)
            .range(offset, offset + limit - 1);

        if (kDebugMode) {
          developer.log(
            'SupabaseVenuesRemoteDatasource.fetchVenues: sem filtro de data, recebidos ${rows.length} registros',
            name: 'SupabaseVenuesRemoteDatasource',
          );
        }
      }

      return _processVenueRows(rows, limit, offset);
    } on PostgrestException catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro PostgreSQL ao buscar venues: ${e.message}',
          name: 'SupabaseVenuesRemoteDatasource',
          error: e,
        );
      }
      return RemotePage(items: []);
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro desconhecido ao buscar venues: $e',
          name: 'SupabaseVenuesRemoteDatasource',
          error: e,
        );
      }
      return RemotePage(items: []);
    }
  }

  Future<RemotePage<VenueDto>> _processVenueRows(
    List<dynamic> rows,
    int limit,
    int offset,
  ) async {
    final List<VenueDto> venues = [];
    for (final row in rows) {
      try {
        final dto = VenueDto.fromMap(Map<String, dynamic>.from(row as Map));
        venues.add(dto);
      } catch (e) {
        if (kDebugMode) {
          developer.log(
            'Erro ao converter venue DTO: $e',
            name: 'SupabaseVenuesRemoteDatasource',
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
        'SupabaseVenuesRemoteDatasource: convertidos ${venues.length} venues, hasMore=$hasMore',
        name: 'SupabaseVenuesRemoteDatasource',
      );
    }

    return RemotePage<VenueDto>(
      items: venues,
      next: hasMore ? nextOffset.toString() : null,
    );
  }

  @override
  Future<int> upsertVenues(List<VenueDto> dtos) async {
    try {
      final client = _client;
      if (client == null) {
        if (kDebugMode) {
          developer.log(
            'SupabaseVenuesRemoteDatasource.upsertVenues: cliente Supabase não inicializado',
            name: 'SupabaseVenuesRemoteDatasource',
          );
        }
        return 0;
      }

      if (dtos.isEmpty) {
        if (kDebugMode) {
          developer.log(
            'SupabaseVenuesRemoteDatasource.upsertVenues: nenhum item para upsert',
            name: 'SupabaseVenuesRemoteDatasource',
          );
        }
        return 0;
      }

      // Comentário: Converter DTOs para mapas para envio ao Supabase
      final maps = dtos.map((dto) => dto.toMap()).toList();

      if (kDebugMode) {
        developer.log(
          'SupabaseVenuesRemoteDatasource.upsertVenues: enviando ${dtos.length} items ao Supabase',
          name: 'SupabaseVenuesRemoteDatasource',
        );
      }

      // Comentário: Usar upsert para insert-or-update
      final response = await client.from('venues').upsert(
        maps,
        onConflict: 'id',
      );

      if (kDebugMode) {
        developer.log(
          'SupabaseVenuesRemoteDatasource.upsertVenues: upsert response length = ${response.length}',
          name: 'SupabaseVenuesRemoteDatasource',
        );
      }

      return response.length;
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro ao fazer upsert de venues: $e',
          name: 'SupabaseVenuesRemoteDatasource',
          error: e,
        );
      }
      return 0;
    }
  }

  @override
  Future<VenueDto> createVenue(VenueDto dto) async {
    try {
      final client = _client;
      if (client == null) {
        throw Exception('Supabase client not initialized');
      }

      if (kDebugMode) {
        developer.log(
          'SupabaseVenuesRemoteDatasource.createVenue: criando novo venue',
          name: 'SupabaseVenuesRemoteDatasource',
        );
      }

      final response = await client.from('venues').insert([dto.toMap()]);
      return VenueDto.fromMap(response[0] as Map<String, dynamic>);
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro ao criar venue: $e',
          name: 'SupabaseVenuesRemoteDatasource',
          error: e,
        );
      }
      rethrow;
    }
  }

  @override
  Future<VenueDto> updateVenue(String id, VenueDto dto) async {
    try {
      final client = _client;
      if (client == null) {
        throw Exception('Supabase client not initialized');
      }

      if (kDebugMode) {
        developer.log(
          'SupabaseVenuesRemoteDatasource.updateVenue: atualizando venue $id',
          name: 'SupabaseVenuesRemoteDatasource',
        );
      }

      final response = await client
          .from('venues')
          .update(dto.toMap())
          .eq('id', id);

      if (response == null || response.isEmpty) {
        throw Exception('Update failed: no rows returned from Supabase');
      }

      return VenueDto.fromMap(response[0] as Map<String, dynamic>);
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro ao atualizar venue: $e',
          name: 'SupabaseVenuesRemoteDatasource',
          error: e,
        );
      }
      rethrow;
    }
  }

  @override
  Future<void> deleteVenue(String id) async {
    try {
      final client = _client;
      if (client == null) {
        throw Exception('Supabase client not initialized');
      }

      if (kDebugMode) {
        developer.log(
          'SupabaseVenuesRemoteDatasource.deleteVenue: deletando venue $id',
          name: 'SupabaseVenuesRemoteDatasource',
        );
      }

      await client.from('venues').delete().eq('id', id);
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro ao deletar venue: $e',
          name: 'SupabaseVenuesRemoteDatasource',
          error: e,
        );
      }
      rethrow;
    }
  }
}
