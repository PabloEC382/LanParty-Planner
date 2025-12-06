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
}
