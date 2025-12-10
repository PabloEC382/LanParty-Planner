import '../dtos/game_dto.dart';
import '../../../../core/models/remote_page.dart';

/// Interface abstrata para operações remotas da entidade Game no Supabase.
///
/// Define o contrato para sincronização de dados com o servidor remoto.
/// Implementações concretas devem gerenciar a comunicação com Supabase,
/// tratamento de erros de rede e conversão de dados.
///
/// ⚠️ Dicas práticas para evitar erros comuns:
/// - Sempre verifique se os dados retornados possuem os campos esperados antes de processar.
/// - Use timestamps em formato ISO8601 para sincronização incremental confiável.
/// - Implemente retry-logic para falhas de rede temporárias.
/// - Nunca exponha secrets em prints/logs (use kDebugMode para logs sensíveis).
/// - Consulte supabase_rls_remediation.md para problemas de autenticação/autorização.
abstract class GamesRemoteApi {
  /// Busca games do servidor Supabase com paginação e filtro por data de atualização.
  /// 
  /// [since] filtra apenas registros atualizados após esta data.
  /// [limit] define o número máximo de resultados (padrão: 500).
  /// [offset] define o deslocamento para paginação (padrão: 0).
  /// 
  /// Retorna uma [RemotePage<GameDto>] contendo a lista de games e cursor para próxima página.
  /// Em caso de erro (network, auth, etc), retorna página vazia ([RemotePage(items: [])]).
  /// 
  /// Boas práticas:
  /// - Use [since] para sincronização incremental (apenas registros novos/atualizados).
  /// - Sempre chame este método com um [limit] adequado para evitar timeout (ex: 500 registros).
  /// - Verifique [RemotePage.hasMore] para determinar se há mais dados a sincronizar.
  /// - Trate exceções graciosamente sem expor detalhes sensíveis.
  Future<RemotePage<GameDto>> fetchGames({
    DateTime? since,
    int limit = 500,
    int offset = 0,
  });

  /// Faz upsert (insert ou update) de games no servidor Supabase.
  /// 
  /// [dtos] lista de GameDtos para sincronizar com o servidor.
  /// 
  /// Retorna o número de linhas reconhecidas pelo servidor (melhor esforço).
  /// Em caso de erro (network, auth, RLS), retorna 0 e registra o erro.
  /// 
  /// Boas práticas:
  /// - Use para push de mudanças locais para o servidor (sync bidirecional).
  /// - Falhas de rede não devem bloquear o pull (pull sempre tenta executar).
  /// - Registre erros em kDebugMode para diagnóstico.
  /// - Consulte supabase_rls_remediation.md para problemas de permissão.
  Future<int> upsertGames(List<GameDto> dtos);

  /// Cria um novo game no servidor Supabase.
  /// 
  /// [dto] GameDto com os dados do novo game.
  /// 
  /// Retorna o GameDto criado com ID confirmado do servidor.
  /// Lança exceção em caso de erro (network, auth, validação).
  /// 
  /// Boas práticas:
  /// - Sempre chame syncFromServer após criar para confirmar sincronização.
  /// - IDs devem ser gerados localmente ou pelo servidor (conforme RLS).
  /// - Registre erros em kDebugMode para diagnóstico.
  Future<GameDto> createGame(GameDto dto);

  /// Atualiza um game existente no servidor Supabase.
  /// 
  /// [id] ID do game a atualizar.
  /// [dto] GameDto com os dados atualizados.
  /// 
  /// Retorna o GameDto atualizado do servidor.
  /// Lança exceção em caso de erro (network, auth, game não encontrado).
  /// 
  /// Boas práticas:
  /// - Sempre use o ID correto do game a atualizar.
  /// - Não modifique created_at e updated_at manualmente.
  /// - Registre erros em kDebugMode para diagnóstico.
  Future<GameDto> updateGame(String id, GameDto dto);

  /// Deleta um game do servidor Supabase.
  /// 
  /// [id] ID do game a deletar.
  /// 
  /// Em caso de erro (network, auth, game não encontrado), lança exceção.
  /// 
  /// Boas práticas:
  /// - Sempre confirme com o usuário antes de deletar.
  /// - Após deletar, remova também do cache local (DAO).
  /// - Registre deletions para auditoria se necessário.
  Future<void> deleteGame(String id);
}

/*
// Exemplo de uso:
final remoteApi = SupabaseGamesRemoteDatasource();
final page = await remoteApi.fetchGames(
  since: DateTime(2024, 1, 1),
  limit: 500,
);
if (page.isNotEmpty) {
  print('Recebidos ${page.length} games');
}

// Dica: combine com o DAO local para implementar sincronização completa:
// 1. Carregar last sync de SharedPreferences
// 2. Chamar fetchGames(since: lastSync)
// 3. Fazer upsert dos DTOs no DAO local
// 4. Atualizar last sync timestamp

// Checklist de erros comuns e como evitar:
// - Erro de conexão: implemente exponential backoff e retry.
// - Dados incompletos: valide que todos os campos obrigatórios estão presentes.
// - Problemas RLS: consulte supabase_rls_remediation.md para permissões corretas.
// - Parsing de data inválido: trate DateTime.parse() em try/catch.

// Referências úteis:
// - supabase_rls_remediation.md
// - supabase_init_debug_prompt.md
*/
