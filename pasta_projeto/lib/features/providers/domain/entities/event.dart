/// Domain entity representing a Lan Party Event.
///
/// This is the internal application model consumed by the UI and business logic.
/// It represents the "ideal format" for internal data manipulation.
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

  /// Convenience getter for UI: displays event summary
  String get summary {
    final taskCount = checklist.length;
    final completedCount = checklist.values.where((done) => done).length;
    return '$name • $completedCount/$taskCount tarefas';
  }

  /// Convenience getter: checks if all tasks are completed
  bool get isComplete => checklist.isNotEmpty && 
                         checklist.values.every((done) => done);

  /// Convenience getter: number of attendees
  int get attendeeCount => attendees.length;

  /// Creates a copy with modified fields (useful for state management)
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