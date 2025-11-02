/// Domain entity representing a Lan Party Event.
///
/// This model is central to the event management feature, defining the
/// structure of an event with its name, date, checklist, and attendees.
class Event {
  final String id;
  final String name;
  final DateTime eventDate;
  final Map<String, bool> checklist;
  final List<String> attendees;
  final DateTime updatedAt;

  Event({
    required this.id,
    required this.name,
    required this.eventDate,
    Map<String, bool>? checklist,
    List<String>? attendees,
    required this.updatedAt,
  })  : checklist = {...?checklist},
        attendees = [...?attendees];

  /// Serialization helper from a Map (e.g., from a DTO).
  /// This is useful for creating a domain object from a data layer object.
  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'] as String,
      name: map['name'] as String,
      eventDate: DateTime.parse(map['eventDate'] as String),
      checklist: Map<String, bool>.from(map['checklist'] as Map),
      attendees: List<String>.from(map['attendees'] as List),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  /// Convert to a Map suitable for serialization (e.g., to a DTO).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'eventDate': eventDate.toIso8601String(),
      'checklist': checklist,
      'attendees': attendees,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
