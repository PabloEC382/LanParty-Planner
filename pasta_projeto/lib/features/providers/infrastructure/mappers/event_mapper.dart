import '../../domain/entities/event.dart';
import '../dtos/event_dto.dart';


class EventMapper {
  static Event toEntity(EventDto dto) {
    return Event(
      id: dto.id,
      name: dto.name,
      startDate: DateTime.parse(dto.start_date),
      endDate: DateTime.parse(dto.end_date),
      description: dto.description,
      startTime: dto.start_time,
      endTime: dto.end_time,
      venueId: dto.venue_id,
      createdAt: DateTime.parse(dto.created_at),
      updatedAt: DateTime.parse(dto.updated_at),
    );
  }

  static EventDto toDto(Event entity) {
    return EventDto(
      id: entity.id,
      name: entity.name,
      start_date: entity.startDate.toIso8601String(),
      end_date: entity.endDate.toIso8601String(),
      description: entity.description,
      start_time: entity.startTime,
      end_time: entity.endTime,
      venue_id: entity.venueId,
      created_at: entity.createdAt.toIso8601String(),
      updated_at: entity.updatedAt.toIso8601String(),
    );
  }

  static List<Event> toEntities(List<EventDto> dtos) {
    return dtos.map(toEntity).toList();
  }
  static List<EventDto> toDtos(List<Event> entities) {
    return entities.map(toDto).toList();
  }
}