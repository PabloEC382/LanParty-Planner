import '../../domain/entities/game.dart';
import '../dtos/game_dto.dart';

class GameMapper {
  static Game toEntity(GameDto dto) {
    Uri? coverUri;
    if (dto.cover_image_url != null && dto.cover_image_url!.isNotEmpty) {
      coverUri = Uri.tryParse(dto.cover_image_url!);
    }

    return Game(
      id: dto.id,
      title: dto.title,
      description: dto.description,
      coverImageUri: coverUri,
      genre: dto.genre,
      minPlayers: dto.min_players,
      maxPlayers: dto.max_players,
      platforms: dto.platforms?.toSet() ?? {},
      averageRating: dto.average_rating,
      totalMatches: dto.total_matches,
      createdAt: DateTime.parse(dto.created_at),
      updatedAt: DateTime.parse(dto.updated_at),
    );
  }

  static GameDto toDto(Game entity) {
    return GameDto(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      cover_image_url: entity.coverImageUri?.toString(),
      genre: entity.genre,
      min_players: entity.minPlayers,
      max_players: entity.maxPlayers,
      platforms: entity.platforms.toList(),
      average_rating: entity.averageRating,
      total_matches: entity.totalMatches,
      created_at: entity.createdAt.toIso8601String(),
      updated_at: entity.updatedAt.toIso8601String(),
    );
  }

  static List<Game> toEntities(List<GameDto> dtos) => dtos.map(toEntity).toList();
  static List<GameDto> toDtos(List<Game> entities) => entities.map(toDto).toList();
}
