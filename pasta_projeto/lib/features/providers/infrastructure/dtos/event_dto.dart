// Allow snake_case field names that mirror the JSON/database columns.
// ignore_for_file: non_constant_identifier_names

/// Data Transfer Object for Event.
///
/// This class mirrors the structure of data as it's stored/transmitted.
/// Field names use snake_case to match the storage format (SharedPreferences JSON).
/// 
/// The DTO is the "wire format" - optimized for data transit and storage.
class EventDto {
  final String id;
  final String name;
  final String event_date; // ISO8601 string
  final Map<String, dynamic> checklist; // Using dynamic for JSON compatibility
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

  /// Creates a DTO from a JSON map (from SharedPreferences or API)
  factory EventDto.fromMap(Map<String, dynamic> map) {
    return EventDto(
      id: map['id'] as String,
      name: map['name'] as String,
      event_date: map['event_date'] as String,
      checklist: Map<String, dynamic>.from(map['checklist'] as Map),
      attendees: List<String>.from(map['attendees'] as List),
      updated_at: map['updated_at'] as String,
    );
  }

  /// Converts the DTO to a JSON map for storage/transmission
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
}