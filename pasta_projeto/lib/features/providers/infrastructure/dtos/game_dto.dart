// ignore_for_file: non_constant_identifier_names

/// Data Transfer Object for Game.
///
/// Mirrors backend structure with snake_case naming.
class GameDto {
  final String id;
  final String title;
  final String? description;
  final String? cover_image_url;
  final String genre;
  final int min_players;
  final int max_players;
  final List<String>? platforms;
  final double average_rating;
  final int total_matches;
  final String created_at; // ISO8601
  final String updated_at; // ISO8601

  GameDto({
    required this.id,
    required this.title,
    this.description,
    this.cover_image_url,
    required this.genre,
    required this.min_players,
    required this.max_players,
    this.platforms,
    required this.average_rating,
    required this.total_matches,
    required this.created_at,
    required this.updated_at,
  });

  factory GameDto.fromMap(Map<String, dynamic> map) {
    return GameDto(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      cover_image_url: map['cover_image_url'] as String?,
      genre: map['genre'] as String,
      min_players: map['min_players'] as int,
      max_players: map['max_players'] as int,
      platforms: (map['platforms'] as List?)?.cast<String>(),
      average_rating: (map['average_rating'] as num).toDouble(),
      total_matches: map['total_matches'] as int,
      created_at: map['created_at'] as String,
      updated_at: map['updated_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'cover_image_url': cover_image_url,
      'genre': genre,
      'min_players': min_players,
      'max_players': max_players,
      'platforms': platforms,
      'average_rating': average_rating,
      'total_matches': total_matches,
      'created_at': created_at,
      'updated_at': updated_at,
    };
  }
}