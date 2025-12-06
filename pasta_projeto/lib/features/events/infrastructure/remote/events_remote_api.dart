import '../dtos/event_dto.dart';
import '../../../../core/models/remote_page.dart';

/// Interface abstrata para operações remotas da entidade Event no Supabase.
///
/// Define o contrato para sincronização de dados com o servidor remoto.
abstract class EventsRemoteApi {
  /// Busca events do servidor Supabase com paginação e filtro por data de atualização.
  Future<RemotePage<EventDto>> fetchEvents({
    DateTime? since,
    int limit = 500,
    int offset = 0,
  });
}
