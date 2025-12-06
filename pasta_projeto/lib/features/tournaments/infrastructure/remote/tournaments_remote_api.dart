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

  /// Faz upsert (insert ou update) de tournaments no servidor Supabase.
  /// 
  /// [dtos] lista de TournamentDtos para sincronizar com o servidor.
  /// 
  /// Retorna o número de linhas reconhecidas pelo servidor (melhor esforço).
  /// Em caso de erro (network, auth, RLS), retorna 0 e registra o erro.
  Future<int> upsertTournaments(List<TournamentDto> dtos);
}
