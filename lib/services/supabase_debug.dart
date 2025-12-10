import 'dart:developer' as developer;
import 'supabase_service.dart';

class SupabaseDebug {
  /// Testa a conexão com Supabase e retorna informações úteis
  static Future<Map<String, dynamic>> testConnection() async {
    final result = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'status': 'unknown',
      'error': null,
      'message': '',
      'tables': <String>[],
      'events_count': 0,
      'games_count': 0,
      'tournaments_count': 0,
      'venues_count': 0,
      'participants_count': 0,
    };

    try {
      final client = SupabaseService.client;
      developer.log('SupabaseDebug.testConnection: cliente obtido com sucesso',
          name: 'SupabaseDebug');

      result['status'] = 'connected';

      // Tentar buscar de cada tabela
      try {
        final eventsData = await client
            .from('events')
            .select('id')
            .limit(1000)
            .then((data) => data as List);
        result['events_count'] = eventsData.length;
        developer.log(
            'SupabaseDebug: events encontrados = ${eventsData.length}',
            name: 'SupabaseDebug');
      } catch (e) {
        developer.log('SupabaseDebug: erro ao buscar events: $e',
            name: 'SupabaseDebug', error: e);
        result['error_events'] = e.toString();
      }

      try {
        final gamesData = await client
            .from('games')
            .select('id')
            .limit(1000)
            .then((data) => data as List);
        result['games_count'] = gamesData.length;
        developer.log('SupabaseDebug: games encontrados = ${gamesData.length}',
            name: 'SupabaseDebug');
      } catch (e) {
        developer.log('SupabaseDebug: erro ao buscar games: $e',
            name: 'SupabaseDebug', error: e);
        result['error_games'] = e.toString();
      }

      try {
        final tournamentsData = await client
            .from('tournaments')
            .select('id')
            .limit(1000)
            .then((data) => data as List);
        result['tournaments_count'] = tournamentsData.length;
        developer.log(
            'SupabaseDebug: tournaments encontrados = ${tournamentsData.length}',
            name: 'SupabaseDebug');
      } catch (e) {
        developer.log('SupabaseDebug: erro ao buscar tournaments: $e',
            name: 'SupabaseDebug', error: e);
        result['error_tournaments'] = e.toString();
      }

      try {
        final venuesData = await client
            .from('venues')
            .select('id')
            .limit(1000)
            .then((data) => data as List);
        result['venues_count'] = venuesData.length;
        developer.log(
            'SupabaseDebug: venues encontrados = ${venuesData.length}',
            name: 'SupabaseDebug');
      } catch (e) {
        developer.log('SupabaseDebug: erro ao buscar venues: $e',
            name: 'SupabaseDebug', error: e);
        result['error_venues'] = e.toString();
      }

      try {
        final participantsData = await client
            .from('participants')
            .select('id')
            .limit(1000)
            .then((data) => data as List);
        result['participants_count'] = participantsData.length;
        developer.log(
            'SupabaseDebug: participants encontrados = ${participantsData.length}',
            name: 'SupabaseDebug');
      } catch (e) {
        developer.log('SupabaseDebug: erro ao buscar participants: $e',
            name: 'SupabaseDebug', error: e);
        result['error_participants'] = e.toString();
      }

      result['message'] = 'Conexão com Supabase OK';
    } catch (e) {
      result['status'] = 'error';
      result['error'] = e.toString();
      result['message'] = 'Erro ao conectar com Supabase: $e';
      developer.log('SupabaseDebug.testConnection: erro: $e',
          name: 'SupabaseDebug', error: e);
    }

    return result;
  }

  /// Teste simples de uma tabela específica
  static Future<List<dynamic>> testTable(String tableName) async {
    try {
      final client = SupabaseService.client;
      final data = await client
          .from(tableName)
          .select()
          .limit(10)
          .then((data) => data as List);
      developer.log('SupabaseDebug.testTable($tableName): ${data.length} registros',
          name: 'SupabaseDebug');
      return data;
    } catch (e) {
      developer.log('SupabaseDebug.testTable($tableName): erro - $e',
          name: 'SupabaseDebug', error: e);
      rethrow;
    }
  }
}
