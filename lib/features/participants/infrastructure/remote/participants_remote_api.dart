import '../dtos/participant_dto.dart';
import '../../../../core/models/remote_page.dart';

abstract class ParticipantsRemoteApi {
  /// Busca participants do servidor Supabase com paginação e filtro por data.
  Future<RemotePage<ParticipantDto>> fetchParticipants({
    DateTime? since,
    int limit = 500,
    int offset = 0,
  });

  /// Faz upsert de participants no servidor Supabase.
  Future<int> upsertParticipants(List<ParticipantDto> dtos);

  /// Cria um novo participant no servidor Supabase.
  Future<ParticipantDto> createParticipant(ParticipantDto dto);

  /// Atualiza um participant existente no servidor Supabase.
  Future<ParticipantDto> updateParticipant(String id, ParticipantDto dto);

  /// Deleta um participant do servidor Supabase.
  Future<void> deleteParticipant(String id);
}
