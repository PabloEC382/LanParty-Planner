import '../../domain/entities/participant.dart';
import '../dtos/participant_dto.dart';

class ParticipantMapper {
  static Participant toEntity(ParticipantDto dto) {
    // Defensive: parse URI safely
    Uri? avatarUri;
    if (dto.avatar_url != null && dto.avatar_url!.isNotEmpty) {
      avatarUri = Uri.tryParse(dto.avatar_url!);
    }

    final games = dto.preferred_games?.toSet() ?? <String>{};

    return Participant(
      id: dto.id,
      name: dto.name,
      email: dto.email,
      avatarUri: avatarUri,
      nickname: dto.nickname,
      skillLevel: dto.skill_level,
      preferredGames: games,
      isPremium: dto.is_premium,
      registeredAt: DateTime.parse(dto.registered_at),
      updatedAt: DateTime.parse(dto.updated_at),
    );
  }

  static ParticipantDto toDto(Participant entity) {
    return ParticipantDto(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      avatar_url: entity.avatarUri?.toString(),
      nickname: entity.nickname,
      skill_level: entity.skillLevel,
      preferred_games: entity.preferredGames.toList(),
      is_premium: entity.isPremium,
      registered_at: entity.registeredAt.toIso8601String(),
      updated_at: entity.updatedAt.toIso8601String(),
    );
  }

  static List<Participant> toEntities(List<ParticipantDto> dtos) {
    return dtos.map(toEntity).toList();
  }

  static List<ParticipantDto> toDtos(List<Participant> entities) {
    return entities.map(toDto).toList();
  }
}
