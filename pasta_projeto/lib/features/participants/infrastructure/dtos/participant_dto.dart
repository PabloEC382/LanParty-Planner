// ignore_for_file: non_constant_identifier_names

class ParticipantDto {
  final String id;
  final String name;
  final String email;
  final String? avatar_url;
  final String nickname;
  final int skill_level;
  final List<String>? preferred_games;
  final bool is_premium;
  final String registered_at;
  final String updated_at;

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