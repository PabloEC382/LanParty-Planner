import '../../domain/entities/event.dart';
import '../dtos/event_dto.dart';


class EventMapper {
  static Event toEntity(EventDto dto) {
    final checklist = <String, bool>{};
    dto.checklist.forEach((key, value) {
      if (value is bool) {
        checklist[key] = value;
      }
    });

    return Event(
      id: dto.id,
      name: dto.name,
      eventDate: DateTime.parse(dto.event_date),
      checklist: checklist,
      attendees: dto.attendees,
      updatedAt: DateTime.parse(dto.updated_at),
    );
  }

  static EventDto toDto(Event entity) {
    return EventDto(
      id: entity.id,
      name: entity.name,
      event_date: entity.eventDate.toIso8601String(),
      checklist: entity.checklist.map((k, v) => MapEntry(k, v)),
      attendees: entity.attendees,
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