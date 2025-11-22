import '../dtos/event_dto.dart';

abstract class EventsLocalDao {
  Future<void> upsertAll(List<EventDto> dtos);
  Future<void> clear();
  Future<EventDto?> getById(String id);
  Future<List<EventDto>> listAll();
}
