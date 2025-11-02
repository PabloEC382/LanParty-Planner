// ignore_for_file: non_constant_identifier_names

/// Data Transfer Object for Participant.
///
/// Mirrors the backend/storage structure exactly.
/// Uses snake_case to match JSON/database conventions.
class ParticipantDto {
  final String id;
  final String name;
  final String email;
  final String? avatar_url; // String as it comes from network
  final String nickname;
  final int skill_level;
  final List<String>? preferred_games; // List in storage, Set in Entity
  final bool is_premium;
  final String registered_at; // ISO8601 string
  final String updated_at; // ISO8601 string

  ParticipantDto({
    required this.id,
    required this.name,
    required this.email,
    this.avatar_url,
    required this.nickname,
    required this.skill_level,
    this.preferred_games,
    required this.is_premium,
    required this.registered_at,
    required this.updated_at,
  });

  /// From JSON map (from storage or API response)
  factory ParticipantDto.fromMap(Map<String, dynamic> map) {
    return ParticipantDto(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      avatar_url: map['avatar_url'] as String?,
      nickname: map['nickname'] as String,
      skill_level: map['skill_level'] as int,
      preferred_games: (map['preferred_games'] as List?)?.cast<String>(),
      is_premium: map['is_premium'] as bool,
      registered_at: map['registered_at'] as String,
      updated_at: map['updated_at'] as String,
    );
  }

  /// To JSON map (for storage or API request)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar_url': avatar_url,
      'nickname': nickname,
      'skill_level': skill_level,
      'preferred_games': preferred_games,
      'is_premium': is_premium,
      'registered_at': registered_at,
      'updated_at': updated_at,
    };
  }
}