import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase_config.dart';
import '../dtos/event_dto.dart';

class EventsRemoteDataSource {
  final SupabaseClient _client = SupabaseConfig.client;

  Future<List<EventDto>> fetchAllEvents() async {
    try {
      final response = await _client
          .from('events')
          .select()
          .order('event_date', ascending: false);

      if (response == null) return [];

      return (response as List)
          .map((json) => EventDto.fromMap(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Erro ao buscar eventos: ${e.message}');
    }
  }

  Future<EventDto?> fetchEventById(String id) async {
    try {
      final response = await _client
          .from('events')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return EventDto.fromMap(response as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      throw Exception('Erro ao buscar evento: ${e.message}');
    }
  }

  Future<EventDto> createEvent(EventDto event) async {
    try {
      final response = await _client
          .from('events')
          .insert(event.toMap())
          .select()
          .single();

      return EventDto.fromMap(response as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      throw Exception('Erro ao criar evento: ${e.message}');
    }
  }

  Future<EventDto> updateEvent(String id, EventDto event) async {
    try {
      final response = await _client
          .from('events')
          .update(event.toMap())
          .eq('id', id)
          .select()
          .single();

      return EventDto.fromMap(response as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      throw Exception('Erro ao atualizar evento: ${e.message}');
    }
  }

  Future<void> deleteEvent(String id) async {
    try {
      await _client.from('events').delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw Exception('Erro ao deletar evento: ${e.message}');
    }
  }

  Future<List<EventDto>> fetchUpcomingEvents() async {
    try {
      final response = await _client
          .from('events')
          .select()
          .gte('event_date', DateTime.now().toIso8601String())
          .order('event_date', ascending: true);

      if (response == null) return [];
      return (response as List)
          .map((json) => EventDto.fromMap(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Erro ao buscar próximos eventos: ${e.message}');
    }
  }

  Future<List<EventDto>> fetchUpdatedEvents(DateTime since) async {
    try {
      final response = await _client
          .from('events')
          .select()
          .gt('updated_at', since.toIso8601String())
          .order('updated_at', ascending: false);

      if (response == null) return [];
      return (response as List)
          .map((json) => EventDto.fromMap(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Erro ao sincronizar eventos: ${e.message}');
    }
  }
}