import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase_config.dart';
import '../dtos/participant_dto.dart';

class ParticipantsRemoteDataSource {
  final SupabaseClient _client = SupabaseConfig.client;

  Future<List<ParticipantDto>> fetchAllParticipants() async {
    try {
      final response = await _client
          .from('participants')
          .select()
          .order('name', ascending: true);

      if (response == null) return [];

      return (response as List)
          .map((json) => ParticipantDto.fromMap(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Erro ao buscar participantes: ${e.message}');
    }
  }

  Future<ParticipantDto?> fetchParticipantById(String id) async {
    try {
      final response = await _client
          .from('participants')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return ParticipantDto.fromMap(response as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      throw Exception('Erro ao buscar participante: ${e.message}');
    }
  }

  Future<ParticipantDto> createParticipant(ParticipantDto participant) async {
    try {
      final response = await _client
          .from('participants')
          .insert(participant.toMap())
          .select()
          .single();

      return ParticipantDto.fromMap(response as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      throw Exception('Erro ao criar participante: ${e.message}');
    }
  }

  Future<ParticipantDto> updateParticipant(String id, ParticipantDto participant) async {
    try {
      final response = await _client
          .from('participants')
          .update(participant.toMap())
          .eq('id', id)
          .select()
          .single();

      return ParticipantDto.fromMap(response as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      throw Exception('Erro ao atualizar participante: ${e.message}');
    }
  }

  Future<void> deleteParticipant(String id) async {
    try {
      await _client.from('participants').delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw Exception('Erro ao deletar participante: ${e.message}');
    }
  }

  Future<List<ParticipantDto>> fetchPremiumParticipants() async {
    try {
      final response = await _client
          .from('participants')
          .select()
          .eq('is_premium', true)
          .order('skill_level', ascending: false);

      if (response == null) return [];
      return (response as List)
          .map((json) => ParticipantDto.fromMap(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Erro ao buscar premium: ${e.message}');
    }
  }
}