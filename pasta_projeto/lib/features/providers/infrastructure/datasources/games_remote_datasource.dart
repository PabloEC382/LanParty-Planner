import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase_config.dart';
import '../dtos/game_dto.dart';

/// Remote data source for games (Supabase)
///
/// Responsabilidades:
/// - Buscar dados do Supabase
/// - Converter JSON → DTO
/// - Tratar erros de rede
class GamesRemoteDataSource {
  final SupabaseClient _client = SupabaseConfig.client;

  /// Busca todos os jogos
  Future<List<GameDto>> fetchAllGames() async {
    try {
      final response = await _client
          .from('games')
          .select()
          .order('title', ascending: true);

      if (response == null) return [];

      return (response as List)
          .map((json) => GameDto.fromMap(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Erro ao buscar jogos: ${e.message}');
    } catch (e) {
      throw Exception('Erro desconhecido ao buscar jogos: $e');
    }
  }

  /// Busca um jogo por ID
  Future<GameDto?> fetchGameById(String id) async {
    try {
      final response = await _client
          .from('games')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;

      return GameDto.fromMap(response as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      throw Exception('Erro ao buscar jogo: ${e.message}');
    }
  }

  /// Cria um novo jogo
  Future<GameDto> createGame(GameDto game) async {
    try {
      final response = await _client
          .from('games')
          .insert(game.toMap())
          .select()
          .single();

      return GameDto.fromMap(response as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      throw Exception('Erro ao criar jogo: ${e.message}');
    }
  }

  /// Atualiza um jogo existente
  Future<GameDto> updateGame(String id, GameDto game) async {
    try {
      final response = await _client
          .from('games')
          .update(game.toMap())
          .eq('id', id)
          .select()
          .single();

      return GameDto.fromMap(response as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      throw Exception('Erro ao atualizar jogo: ${e.message}');
    }
  }

  /// Deleta um jogo
  Future<void> deleteGame(String id) async {
    try {
      await _client
          .from('games')
          .delete()
          .eq('id', id);
    } on PostgrestException catch (e) {
      throw Exception('Erro ao deletar jogo: ${e.message}');
    }
  }

  /// Busca jogos por gênero
  Future<List<GameDto>> fetchGamesByGenre(String genre) async {
    try {
      final response = await _client
          .from('games')
          .select()
          .eq('genre', genre)
          .order('average_rating', ascending: false);

      if (response == null) return [];

      return (response as List)
          .map((json) => GameDto.fromMap(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Erro ao buscar jogos por gênero: ${e.message}');
    }
  }

  /// Busca jogos atualizados após uma data (sync incremental)
  Future<List<GameDto>> fetchUpdatedGames(DateTime since) async {
    try {
      final response = await _client
          .from('games')
          .select()
          .gt('updated_at', since.toIso8601String())
          .order('updated_at', ascending: false);

      if (response == null) return [];

      return (response as List)
          .map((json) => GameDto.fromMap(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Erro ao sincronizar jogos: ${e.message}');
    }
  }
}