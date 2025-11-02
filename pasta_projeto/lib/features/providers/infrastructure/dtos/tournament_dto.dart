// ignore_for_file: non_constant_identifier_names

/// Data Transfer Object for Tournament.
///
/// Uses snake_case and stores enums as strings for JSON compatibility.
class TournamentDto {
  final String id;
  final String name;
  final String? description;
  final String game_id;
  final String format; // String representation of enum
  final String status; // String representation of enum
  final int max_participants;
  final int current_participants;
  final double prize_pool;
  final String start_date; // ISO8601
  final String? end_date; // ISO8601
  final List<String>? organizer_ids;
  final Map<String, dynamic>? rules;
  final String created_at; // ISO8601
  final String updated_at; // ISO8601

  TournamentDto({
    required this.id,
    required this.name,
    this.description,
    required this.game_id,
    required this.format,
    required this.status,
    required this.max_participants,
    required this.current_participants,
    required this.prize_pool,
    required this.start_date,
    this.end_date,
    this.organizer_ids,
    this.rules,
    required this.created_at,
    required this.updated_at,
  });

  factory TournamentDto.fromMap(Map<String, dynamic> map) {
    return TournamentDto(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      game_id: map['game_id'] as String,
      format: map['format'] as String,
      status: map['status'] as String,
      max_participants: map['max_participants'] as int,
      current_participants: map['current_participants'] as int,
      prize_pool: (map['prize_pool'] as num).toDouble(),
      start_date: map['start_date'] as String,
      end_date: map['end_date'] as String?,
      organizer_ids: (map['organizer_ids'] as List?)?.cast<String>(),
      rules: map['rules'] as Map<String, dynamic>?,
      created_at: map['created_at'] as String,
      updated_at: map['updated_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'game_id': game_id,
      'format': format,
      'status': status,
      'max_participants': max_participants,
      'current_participants': current_participants,
      'prize_pool': prize_pool,
      'start_date': start_date,
      'end_date': end_date,
      'organizer_ids': organizer_ids,
      'rules': rules,
      'created_at': created_at,
      'updated_at': updated_at,
    };
  }
}