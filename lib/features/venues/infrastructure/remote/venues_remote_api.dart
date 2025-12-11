import '../dtos/venue_dto.dart';
import '../../../../core/models/remote_page.dart';

abstract class VenuesRemoteApi {
  /// Busca venues do servidor Supabase com paginação e filtro por data.
  Future<RemotePage<VenueDto>> fetchVenues({
    DateTime? since,
    int limit = 500,
    int offset = 0,
  });

  /// Faz upsert de venues no servidor Supabase.
  Future<int> upsertVenues(List<VenueDto> dtos);

  /// Cria um novo venue no servidor Supabase.
  Future<VenueDto> createVenue(VenueDto dto);

  /// Atualiza um venue existente no servidor Supabase.
  Future<VenueDto> updateVenue(String id, VenueDto dto);

  /// Deleta um venue do servidor Supabase.
  Future<void> deleteVenue(String id);
}
