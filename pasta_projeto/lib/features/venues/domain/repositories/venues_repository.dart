import '../entities/venue.dart';

/// Interface de repositório para a entidade Venue.
///
/// O repositório define as operações de acesso e sincronização de dados,
/// separando a lógica de persistência da lógica de negócio.
/// Utilizar interfaces facilita a troca de implementações (ex.: local, remota)
/// e torna o código mais testável e modular.
///
/// ⚠️ Dicas práticas para evitar erros comuns:
/// - Certifique-se de que a entidade Venue possui métodos de conversão robustos (ex: aceitar id como int ou string, datas como DateTime ou String).
/// - Ao implementar esta interface, adicione prints/logs (usando kDebugMode) nos métodos principais para facilitar o diagnóstico de problemas de cache, conversão e sync.
/// - Em métodos assíncronos usados na UI, sempre verifique se o widget está "mounted" antes de chamar setState, evitando exceções de widget desmontado.
/// - Consulte os arquivos de debug do projeto (ex: venues_cache_debug_prompt.md, supabase_init_debug_prompt.md, supabase_rls_remediation.md) para exemplos de logs, prints e soluções de problemas reais.
abstract class VenuesRepository {
  /// Render inicial rápido a partir do cache local.
  /// Este método retorna os dados já em cache sem fazer requisições ao servidor.
  /// Use este método na inicialização da UI para exibir dados instantaneamente.
  /// Boas práticas:
  /// - Sempre verifique se o cache está vazio antes de exibir na UI.
  /// - Se o cache estiver vazio, considere chamar syncFromServer() em seguida.
  Future<List<Venue>> loadFromCache();

  /// Sincronização incremental (>= lastSync). Retorna quantos registros mudaram.
  /// Este método sincroniza apenas os registros que foram modificados desde a última sincronização.
  /// Boas práticas:
  /// - Use este método em background para manter os dados sempre atualizados.
  /// - Trate erros de rede graciosamente, mantendo os dados locais intactos.
  /// - Considere usar retry-logic para garantir a sincronização em caso de falha temporária.
  /// - Adicione logs detalhados para monitorar quantos registros foram sincronizados.
  Future<int> syncFromServer();

  /// Listagem completa (normalmente do cache após sync).
  /// Este método retorna todos os locais (venues) disponíveis no cache.
  /// Boas práticas:
  /// - Sempre chame syncFromServer() antes de chamar este método para garantir dados atualizados.
  /// - Use este método para popular listas na UI.
  /// - Considere adicionar paginação para grandes volumes de dados.
  Future<List<Venue>> listAll();

  /// Destaques (filtrados do cache por `featured`).
  /// Este método retorna apenas os locais destacados/em destaque.
  /// Boas práticas:
  /// - Assegure-se de que a entidade Venue possui um campo para marcar locais em destaque.
  /// - Use este método para exibir seções especiais na UI (ex: "Locais em Destaque").
  /// - O filtro deve ocorrer localmente no cache, não no servidor.
  Future<List<Venue>> listFeatured();

  /// Opcional: busca direta por ID no cache.
  /// Este método busca um local específico pelo seu ID.
  /// Boas práticas:
  /// - Verifique se o cache contém o ID antes de fazer requisições remotas.
  /// - Retorne null se o local não for encontrado no cache.
  /// - Para buscas que necessitam de dados remotos, considere implementar uma versão remota desta interface.
  Future<Venue?> getById(int id);
}

/*
// Exemplo de uso:
final repo = MinhaImplementacaoDeVenuesRepository();
final lista = await repo.listAll();

// Dica: implemente esta interface usando um DAO local e um datasource remoto.
// Para testes, crie um mock que retorna dados fixos.

// Checklist de erros comuns e como evitar:
// - Erro de conversão de tipos (ex: id como string): ajuste o fromMap/toMap da entidade/DTO para aceitar múltiplos formatos.
// - Falha ao atualizar UI após sync: verifique se o widget está mounted antes de chamar setState.
// - Dados não aparecem após sync: adicione prints/logs para inspecionar o conteúdo do cache e o fluxo de conversão.
// - Problemas com Supabase (RLS, inicialização): consulte supabase_rls_remediation.md e supabase_init_debug_prompt.md.

// Referências úteis:
// - venues_cache_debug_prompt.md
// - supabase_init_debug_prompt.md
// - supabase_rls_remediation.md
*/
