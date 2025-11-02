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

  String get summary {
    final taskCount = checklist.length;
    final completedCount = checklist.values.where((done) => done).length;
    return '$name • $completedCount/$taskCount tarefas';
  }

  bool get isComplete => checklist.isNotEmpty && 
                         checklist.values.every((done) => done);

  int get attendeeCount => attendees.length;

  Event copyWith({
    String? id,
    String? name,
    DateTime? eventDate,
    Map<String, bool>? checklist,
    List<String>? attendees,
    DateTime? updatedAt,
  }) {
    return Event(
      id: id ?? this.id,
      name: name ?? this.name,
      eventDate: eventDate ?? this.eventDate,
      checklist: checklist ?? this.checklist,
      attendees: attendees ?? this.attendees,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}