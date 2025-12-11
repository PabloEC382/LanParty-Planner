import '../dtos/event_dto.dart';
import '../../../../core/models/remote_page.dart';

abstract class EventsRemoteApi {
  /// Busca events do servidor Supabase com paginação e filtro por data.
  Future<RemotePage<EventDto>> fetchEvents({
    DateTime? since,
    int limit = 500,
    int offset = 0,
  });

  /// Faz upsert de events no servidor Supabase.
  Future<int> upsertEvents(List<EventDto> dtos);

  /// Cria um novo event no servidor Supabase.
  Future<EventDto> createEvent(EventDto dto);

  /// Atualiza um event existente no servidor Supabase.
  Future<EventDto> updateEvent(String id, EventDto dto);

  /// Deleta um event do servidor Supabase.
  Future<void> deleteEvent(String id);
}
