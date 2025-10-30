// Allow snake_case field names that mirror the JSON/database columns.
// ignore_for_file: non_constant_identifier_names

import '../../domain/entities/provider.dart';

/// Data Transfer Object for an [Event].
///
/// This class is used for serializing and deserializing event data
/// from a persistent source (like JSON from SharedPreferences).
/// It uses snake_case for its field names to match the storage format.
class EventDto {
  final String id;
  final String name;
  final String event_date; // ISO8601 string
  final Map<String, bool> checklist;
  final List<String> attendees;
  final String updated_at; // ISO8601 string

  EventDto({
    required this.id,
    required this.name,
    required this.event_date,
    required this.checklist,
    required this.attendees,
    required this.updated_at,
  });

  /// Creates a DTO from a map (typically from JSON).
  factory EventDto.fromMap(Map<String, dynamic> map) {
    return EventDto(
      id: map['id'] as String,
      name: map['name'] as String,
      event_date: map['event_date'] as String,
      checklist: Map<String, bool>.from(map['checklist'] as Map),
      attendees: List<String>.from(map['attendees'] as List),
      updated_at: map['updated_at'] as String,
    );
  }

    /// Creates a DTO from a domain [Event] entity.
  factory EventDto.fromEntity(Event entity) {
    return EventDto(
      id: entity.id,
      name: entity.name,
      event_date: entity.eventDate.toIso8601String(),
      checklist: entity.checklist,
      attendees: entity.attendees,
      updated_at: entity.updatedAt.toIso8601String(),
    );
  }

  /// Converts the DTO to a map for JSON serialization.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'event_date': event_date,
      'checklist': checklist,
      'attendees': attendees,
      'updated_at': updated_at,
    };
  }

  /// Converts the DTO to a domain [Event] entity.
  Event toEntity() {
    return Event(
      id: id,
      name: name,
      eventDate: DateTime.parse(event_date),
      checklist: checklist,
      attendees: attendees,
      updatedAt: DateTime.parse(updated_at),
    );
  }
}
