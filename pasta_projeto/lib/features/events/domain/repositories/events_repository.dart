import '../entities/event.dart';

abstract class EventsRepository {
  /// Lista todos os eventos
  Future<List<Event>> listAll();

  /// Busca um evento por ID
  Future<Event?> getById(String id);

  /// Cria um novo evento
  Future<Event> create(Event event);

  /// Atualiza um evento existente
  Future<Event> update(Event event);

  /// Deleta um evento por ID
  Future<void> delete(String id);

  /// Sincroniza eventos locais com o servidor
  Future<void> sync();

  /// Limpa o cache local
  Future<void> clearCache();
}
