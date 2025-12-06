import '../dtos/participant_dto.dart';
import '../../../../core/models/remote_page.dart';

/// Interface abstrata para operações remotas da entidade Participant no Supabase.
///
/// Define o contrato para sincronização de dados com o servidor remoto.
abstract class ParticipantsRemoteApi {
  /// Busca participants do servidor Supabase com paginação e filtro por data de atualização.
  Future<RemotePage<ParticipantDto>> fetchParticipants({
    DateTime? since,
    int limit = 500,
    int offset = 0,
  });

  /// Faz upsert (insert ou update) de participants no servidor Supabase.
  /// 
  /// [dtos] lista de ParticipantDtos para sincronizar com o servidor.
  /// 
  /// Retorna o número de linhas reconhecidas pelo servidor (melhor esforço).
  /// Em caso de erro (network, auth, RLS), retorna 0 e registra o erro.
  Future<int> upsertParticipants(List<ParticipantDto> dtos);
}
