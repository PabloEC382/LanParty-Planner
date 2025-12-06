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
}
