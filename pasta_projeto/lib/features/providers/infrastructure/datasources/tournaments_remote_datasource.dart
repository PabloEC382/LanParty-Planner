import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase_config.dart';
import '../dtos/tournament_dto.dart';

class TournamentsRemoteDataSource {
  final SupabaseClient _client = SupabaseConfig.client;

  Future<List<TournamentDto>> fetchAllTournaments() async {
    try {
      final response = await _client
          .from('tournaments')
          .select()
          .order('start_date', ascending: false);

      if (response == null) return [];

      return (response as List)
          .map((json) => TournamentDto.fromMap(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Erro ao buscar torneios: ${e.message}');
    }
  }

  Future<TournamentDto?> fetchTournamentById(String id) async {
    try {
      final response = await _client
          .from('tournaments')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return TournamentDto.fromMap(response as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      throw Exception('Erro ao buscar torneio: ${e.message}');
    }
  }

  Future<TournamentDto> createTournament(TournamentDto tournament) async {
    try {
      final response = await _client
          .from('tournaments')
          .insert(tournament.toMap())
          .select()
          .single();

      return TournamentDto.fromMap(response as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      throw Exception('Erro ao criar torneio: ${e.message}');
    }
  }

  Future<TournamentDto> updateTournament(String id, TournamentDto tournament) async {
    try {
      final response = await _client
          .from('tournaments')
          .update(tournament.toMap())
          .eq('id', id)
          .select()
          .single();

      return TournamentDto.fromMap(response as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      throw Exception('Erro ao atualizar torneio: ${e.message}');
    }
  }

  Future<void> deleteTournament(String id) async {
    try {
      await _client.from('tournaments').delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw Exception('Erro ao deletar torneio: ${e.message}');
    }
  }

  Future<List<TournamentDto>> fetchActiveRegistrations() async {
    try {
      final response = await _client
          .from('tournaments')
          .select()
          .eq('status', 'registration')
          .order('start_date', ascending: true);

      if (response == null) return [];
      return (response as List)
          .map((json) => TournamentDto.fromMap(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Erro ao buscar registrations: ${e.message}');
    }
  }

  Future<List<TournamentDto>> fetchTournamentsByGame(String gameId) async {
    try {
      final response = await _client
          .from('tournaments')
          .select()
          .eq('game_id', gameId)
          .order('start_date', ascending: false);

      if (response == null) return [];
      return (response as List)
          .map((json) => TournamentDto.fromMap(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Erro ao buscar torneios do jogo: ${e.message}');
    }
  }
}