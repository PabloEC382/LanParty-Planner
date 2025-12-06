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

  /// Faz upsert (insert ou update) de events no servidor Supabase.
  /// 
  /// [dtos] lista de EventDtos para sincronizar com o servidor.
  /// 
  /// Retorna o número de linhas reconhecidas pelo servidor (melhor esforço).
  /// Em caso de erro (network, auth, RLS), retorna 0 e registra o erro.
  Future<int> upsertEvents(List<EventDto> dtos);
}
