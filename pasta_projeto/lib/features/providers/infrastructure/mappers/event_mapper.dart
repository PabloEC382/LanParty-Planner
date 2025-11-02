import '../../domain/entities/event.dart';
import '../dtos/event_dto.dart';

/// Mapper between EventDto (wire format) and Event (domain model).
///
/// This is the "single source of truth" for conversions between the two representations.
/// Following the architecture from the PDF, this ensures:
/// - Isolation of changes (if storage format changes, only this file needs updates)
/// - Quality and predictability (all conversions in one place)
/// - Easy testing (mock conversions without network/storage)
class EventMapper {
  /// Converts a DTO (from storage/network) to an Entity (for app use)
  static Event toEntity(EventDto dto) {
    // Defensive reading: convert dynamic map to Map<String, bool>
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

  /// Converts an Entity (from app) to a DTO (for storage/network)
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

  /// Batch conversion: List of DTOs to List of Entities
  static List<Event> toEntities(List<EventDto> dtos) {
    return dtos.map(toEntity).toList();
  }

  /// Batch conversion: List of Entities to List of DTOs
  static List<EventDto> toDtos(List<Event> entities) {
    return entities.map(toDto).toList();
  }
}