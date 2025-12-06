import '../dtos/venue_dto.dart';
import '../../../../core/models/remote_page.dart';

/// Interface abstrata para operações remotas da entidade Venue no Supabase.
///
/// Define o contrato para sincronização de dados com o servidor remoto.
abstract class VenuesRemoteApi {
  /// Busca venues do servidor Supabase com paginação e filtro por data de atualização.
  Future<RemotePage<VenueDto>> fetchVenues({
    DateTime? since,
    int limit = 500,
    int offset = 0,
  });
}
