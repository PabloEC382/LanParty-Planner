class EventDto {
  final String id;
  final String name;
  final String start_date;
  final String end_date;
  final String description;
  final String start_time;
  final String end_time;
  final String? venue_id;
  final String created_at;
  final String updated_at;

  EventDto({
    required this.id,
    required this.name,
    required this.start_date,
    required this.end_date,
    required this.description,
    required this.start_time,
    required this.end_time,
    this.venue_id,
    required this.created_at,
    required this.updated_at,
  });

  factory EventDto.fromMap(Map<String, dynamic> map) {
    return EventDto(
      id: map['id'] as String,
      name: map['name'] as String,
      start_date: map['start_date'] as String,
      end_date: map['end_date'] as String,
      description: map['description'] as String,
      start_time: map['start_time'] as String,
      end_time: map['end_time'] as String,
      venue_id: map['venue_id'] as String?,
      created_at: map['created_at'] as String,
      updated_at: map['updated_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'start_date': start_date,
      'end_date': end_date,
      'description': description,
      'start_time': start_time,
      'end_time': end_time,
      'venue_id': venue_id,
      'created_at': created_at,
      'updated_at': updated_at,
    };
  }
}