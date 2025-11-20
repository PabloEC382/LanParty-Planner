class Event {
  final String id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final String description;
  final String startTime; // formato HH:mm
  final String endTime; // formato HH:mm
  final String? venueId; // referência ao local (nullable)
  final DateTime createdAt;
  final DateTime updatedAt;

  Event({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.description,
    required this.startTime,
    required this.endTime,
    this.venueId,
    required this.createdAt,
    required this.updatedAt,
  });

  // Getters úteis
  String get venueName => venueId ?? 'Local não definido';
  
  String get fullDateTime => 
      '$startDate às $startTime até $endTime';

  Event copyWith({
    String? id,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    String? description,
    String? startTime,
    String? endTime,
    String? venueId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Event(
      id: id ?? this.id,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      venueId: venueId ?? this.venueId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}