class Game {
  final String id;
  final String title;
  final String? description;
  final Uri? coverImageUri;
  final String genre;
  final int minPlayers;
  final int maxPlayers;
  final Set<String> platforms;
  final double averageRating;
  final int totalMatches;
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
  })  : minPlayers = minPlayers < 1 ? 1 : minPlayers,
        maxPlayers = maxPlayers < minPlayers ? minPlayers : maxPlayers, 
        averageRating = averageRating.clamp(0.0, 5.0),
        totalMatches = totalMatches < 0 ? 0 : totalMatches,
        platforms = {...?platforms};

  String get playerRange => '$minPlayers-$maxPlayers jogadores';

  String get ratingDisplay => '${'⭐' * averageRating.round()} ${averageRating.toStringAsFixed(1)}';

  String get platformsDisplay => platforms.isEmpty ? 'N/A' : platforms.join(', ');

  bool get isPopular => totalMatches >= 50;

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