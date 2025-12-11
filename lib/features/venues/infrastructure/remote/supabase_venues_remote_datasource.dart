import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../dtos/venue_dto.dart';
import '../../../../core/models/remote_page.dart';
import '../../../../services/supabase_service.dart';
import 'venues_remote_api.dart';

class SupabaseVenuesRemoteDatasource implements VenuesRemoteApi {
  static const String _tableName = 'venues';
  final SupabaseClient? _providedClient;

  SupabaseVenuesRemoteDatasource({SupabaseClient? client})
    : _providedClient = client;

  SupabaseClient get _client => _providedClient ?? SupabaseService.client;

  @override
  Future<RemotePage<VenueDto>> fetchVenues({
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
      final response = await _client
          .from(_tableName)
          .upsert(maps, onConflict: 'id');

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
      if (kDebugMode) {
        developer.log(
          'SupabaseVenuesRemoteDatasource.createVenue: criando novo venue',
          name: 'SupabaseVenuesRemoteDatasource',
        );
      }

      final response = await _client.from(_tableName).insert([
        dto.toMap(),
      ]).select();
      if (response.isEmpty) {
        throw Exception('Create failed: no rows returned from Supabase');
      }
      return VenueDto.fromMap(response[0]);
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
      if (kDebugMode) {
        developer.log(
          'SupabaseVenuesRemoteDatasource.updateVenue: atualizando venue $id',
          name: 'SupabaseVenuesRemoteDatasource',
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

      return VenueDto.fromMap(response[0]);
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
      if (kDebugMode) {
        developer.log(
          'SupabaseVenuesRemoteDatasource.deleteVenue: deletando venue id=$id (type=${id.runtimeType})',
          name: 'SupabaseVenuesRemoteDatasource',
        );
      }

      final response = await _client.from(_tableName).delete().eq('id', id);
      if (kDebugMode) {
        developer.log(
          'SupabaseVenuesRemoteDatasource.deleteVenue: resposta=$response',
          name: 'SupabaseVenuesRemoteDatasource',
        );
      }
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
