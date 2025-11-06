class EventDto {
  final String id;
  final String name;
  final String event_date;
  final Map<String, dynamic> checklist;
  final List<String> attendees;
  final String updated_at;

  EventDto({
    required this.id,
    required this.name,
    required this.event_date,
    required this.checklist,
    required this.attendees,
    required this.updated_at,
  });

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