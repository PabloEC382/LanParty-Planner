/// Domain entity representing a Game in the gaming event platform.
///
/// Strong typing and domain invariants ensure data integrity.
class Game {
  final String id;
  final String title;
  final String? description;
  final Uri? coverImageUri;
  final String genre; // e.g., "FPS", "MOBA", "RPG"
  final int minPlayers; // Minimum 1
  final int maxPlayers; // Minimum 1, must be >= minPlayers
  final Set<String> platforms; // PC, PS5, Xbox, etc.
  final double averageRating; // 0.0 to 5.0, clamped
  final int totalMatches; // Non-negative
  final DateTime createdAt;
  final DateTime updatedAt;

  Game({
    required this.id,
    required this.title,
    this.description,
    this.coverImageUri,
    required this.genre,
    required int minPlayers,
    required int maxPlayers,
    Set<String>? platforms,
    required double averageRating,
    required int totalMatches,
    required this.createdAt,
    required this.updatedAt,
  })  : minPlayers = minPlayers < 1 ? 1 : minPlayers, // Invariant: min 1 player
        maxPlayers = maxPlayers < minPlayers ? minPlayers : maxPlayers, // Invariant: max >= min
        averageRating = averageRating.clamp(0.0, 5.0), // Invariant: rating 0-5
        totalMatches = totalMatches < 0 ? 0 : totalMatches, // Invariant: non-negative
        platforms = {...?platforms};

  /// Convenience: Player range display
  String get playerRange => '$minPlayers-$maxPlayers jogadores';

  /// Convenience: Rating with stars
  String get ratingDisplay => '${'⭐' * averageRating.round()} ${averageRating.toStringAsFixed(1)}';

  /// Convenience: Formatted platforms
  String get platformsDisplay => platforms.isEmpty ? 'N/A' : platforms.join(', ');

  /// Convenience: Check if game is popular (many matches)
  bool get isPopular => totalMatches >= 50;

  /// Convenience: Short description (first 100 chars)
  String get shortDescription {
    if (description == null || description!.isEmpty) return 'Sem descrição';
    return description!.length > 100 
        ? '${description!.substring(0, 100)}...' 
        : description!;
  }

  Game copyWith({
    String? id,
    String? title,
    String? description,
    Uri? coverImageUri,
    String? genre,
    int? minPlayers,
    int? maxPlayers,
    Set<String>? platforms,
    double? averageRating,
    int? totalMatches,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Game(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      coverImageUri: coverImageUri ?? this.coverImageUri,
      genre: genre ?? this.genre,
      minPlayers: minPlayers ?? this.minPlayers,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      platforms: platforms ?? this.platforms,
      averageRating: averageRating ?? this.averageRating,
      totalMatches: totalMatches ?? this.totalMatches,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}