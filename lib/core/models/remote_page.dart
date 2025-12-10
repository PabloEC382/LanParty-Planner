/// Modelo genérico para representar uma página de dados remotos com suporte a paginação.
/// 
/// Este modelo é utilizado por datasources remotos (ex: Supabase) para retornar
/// resultados paginados de forma estruturada. Facilita o controle de sincronização
/// incremental e implementação de lazy loading na UI.
/// 
/// ⚠️ Dicas práticas para evitar erros comuns:
/// - Use [next] para determinar se há mais dados a sincronizar.
/// - Combine com [items] para processar dados em lotes.
/// - Sempre verifique se [items] está vazio antes de processar para evitar loops infinitos.
class RemotePage<T> {
  /// Lista de itens retornados nesta página.
  /// Pode estar vazia se não há dados disponíveis.
  final List<T> items;

  /// Cursor para a próxima página, ou null se não há mais dados.
  /// Use este valor para fazer a próxima requisição com paginação.
  /// Tipicamente é um offset (ex: "500", "1000") ou um timestamp.
  final String? next;

  /// Cria uma nova instância de RemotePage.
  /// 
  /// [items] lista de dados desta página (pode ser vazia).
  /// [next] cursor para a próxima página ou null se esta é a última.
  RemotePage({
    required this.items,
    this.next,
  });

  /// Verifica se há mais dados a sincronizar.
  /// Retorna true se [next] é não-nulo e não-vazio.
  bool get hasMore => next != null && next!.isNotEmpty;

  /// Verifica se a página está vazia.
  bool get isEmpty => items.isEmpty;

  /// Verifica se a página tem dados.
  bool get isNotEmpty => items.isNotEmpty;

  /// Retorna o número de itens nesta página.
  int get length => items.length;

  @override
  String toString() => 'RemotePage(items: ${items.length}, hasMore: $hasMore)';
}

/*
// Exemplo de uso em um remote datasource:
final page = await RemoteDatasource.fetchGames(since: lastSync, limit: 500);
if (page.isNotEmpty) {
  await localDao.upsertAll(page.items);
}
if (page.hasMore) {
  // Há mais dados a sincronizar - chamar novamente com next cursor
}

// Dica: implemente lógica de retry e backoff exponencial para casos de falha.
// Referências úteis:
// - supabase_init_debug_prompt.md
// - supabase_rls_remediation.md
*/
