import '../dtos/tournament_dto.dart';
import '../../../../core/models/remote_page.dart';

/// Interface abstrata para operações remotas da entidade Tournament no Supabase.
///
/// Define o contrato para sincronização de dados com o servidor remoto.
/// Implementações concretas devem gerenciar a comunicação com Supabase,
/// tratamento de erros de rede e conversão de dados.
abstract class TournamentsRemoteApi {
  /// Busca tournaments do servidor Supabase com paginação e filtro por data de atualização.
  Future<RemotePage<TournamentDto>> fetchTournaments({
    DateTime? since,
    int limit = 500,
    int offset = 0,
  });
}
