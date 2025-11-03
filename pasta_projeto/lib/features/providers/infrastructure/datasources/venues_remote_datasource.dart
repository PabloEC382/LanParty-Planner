import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase_config.dart';
import '../dtos/venue_dto.dart';

class VenuesRemoteDataSource {
  final SupabaseClient _client = SupabaseConfig.client;

  Future<List<VenueDto>> fetchAllVenues() async {
    try {
      final response = await _client
          .from('venues')
          .select()
          .order('name', ascending: true);

      if (response == null) return [];

      return (response as List)
          .map((json) => VenueDto.fromMap(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Erro ao buscar locais: ${e.message}');
    }
  }

  Future<VenueDto?> fetchVenueById(String id) async {
    try {
      final response = await _client
          .from('venues')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return VenueDto.fromMap(response as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      throw Exception('Erro ao buscar local: ${e.message}');
    }
  }

  Future<VenueDto> createVenue(VenueDto venue) async {
    try {
      final response = await _client
          .from('venues')
          .insert(venue.toMap())
          .select()
          .single();

      return VenueDto.fromMap(response as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      throw Exception('Erro ao criar local: ${e.message}');
    }
  }

  Future<VenueDto> updateVenue(String id, VenueDto venue) async {
    try {
      final response = await _client
          .from('venues')
          .update(venue.toMap())
          .eq('id', id)
          .select()
          .single();

      return VenueDto.fromMap(response as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      throw Exception('Erro ao atualizar local: ${e.message}');
    }
  }

  Future<void> deleteVenue(String id) async {
    try {
      await _client.from('venues').delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw Exception('Erro ao deletar local: ${e.message}');
    }
  }

  Future<List<VenueDto>> fetchVerifiedVenues() async {
    try {
      final response = await _client
          .from('venues')
          .select()
          .eq('is_verified', true)
          .order('rating', ascending: false);

      if (response == null) return [];
      return (response as List)
          .map((json) => VenueDto.fromMap(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Erro ao buscar verificados: ${e.message}');
    }
  }

  Future<List<VenueDto>> fetchVenuesByCity(String city) async {
    try {
      final response = await _client
          .from('venues')
          .select()
          .eq('city', city)
          .order('rating', ascending: false);

      if (response == null) return [];
      return (response as List)
          .map((json) => VenueDto.fromMap(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Erro ao buscar por cidade: ${e.message}');
    }
  }
}