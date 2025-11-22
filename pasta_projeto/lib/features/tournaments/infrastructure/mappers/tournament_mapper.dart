import '../../domain/entities/tournament.dart';
import '../dtos/tournament_dto.dart';

class TournamentMapper {
  static Tournament toEntity(TournamentDto dto) {
    TournamentFormat format = TournamentFormat.singleElimination;
    switch (dto.format.toLowerCase()) {
      case 'single_elimination': format = TournamentFormat.singleElimination; break;
      case 'double_elimination': format = TournamentFormat.doubleElimination; break;
      case 'round_robin': format = TournamentFormat.roundRobin; break;
      case 'swiss': format = TournamentFormat.swiss; break;
    }

    TournamentStatus status = TournamentStatus.draft;
    switch (dto.status.toLowerCase()) {
      case 'draft': status = TournamentStatus.draft; break;
      case 'registration': status = TournamentStatus.registration; break;
      case 'in_progress': status = TournamentStatus.inProgress; break;
      case 'finished': status = TournamentStatus.finished; break;
      case 'cancelled': status = TournamentStatus.cancelled; break;
    }

    return Tournament(
      id: dto.id,
      name: dto.name,
      description: dto.description,
      gameId: dto.game_id,
      format: format,
      status: status,
      maxParticipants: dto.max_participants,
      currentParticipants: dto.current_participants,
      prizePool: dto.prize_pool,
      startDate: DateTime.parse(dto.start_date),
      endDate: dto.end_date != null ? DateTime.parse(dto.end_date!) : null,
      organizerIds: dto.organizer_ids?.toSet(),
      rules: dto.rules,
      createdAt: DateTime.parse(dto.created_at),
      updatedAt: DateTime.parse(dto.updated_at),
    );
  }

  static TournamentDto toDto(Tournament entity) {
    // Convert enum to string
    String formatStr = '';
    switch (entity.format) {
      case TournamentFormat.singleElimination: formatStr = 'single_elimination'; break;
      case TournamentFormat.doubleElimination: formatStr = 'double_elimination'; break;
      case TournamentFormat.roundRobin: formatStr = 'round_robin'; break;
      case TournamentFormat.swiss: formatStr = 'swiss'; break;
    }

    String statusStr = '';
    switch (entity.status) {
      case TournamentStatus.draft: statusStr = 'draft'; break;
      case TournamentStatus.registration: statusStr = 'registration'; break;
      case TournamentStatus.inProgress: statusStr = 'in_progress'; break;
      case TournamentStatus.finished: statusStr = 'finished'; break;
      case TournamentStatus.cancelled: statusStr = 'cancelled'; break;
    }

    return TournamentDto(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      game_id: entity.gameId,
      format: formatStr,
      status: statusStr,
      max_participants: entity.maxParticipants,
      current_participants: entity.currentParticipants,
      prize_pool: entity.prizePool,
      start_date: entity.startDate.toIso8601String(),
      end_date: entity.endDate?.toIso8601String(),
      organizer_ids: entity.organizerIds.toList(),
      rules: entity.rules,
      created_at: entity.createdAt.toIso8601String(),
      updated_at: entity.updatedAt.toIso8601String(),
    );
  }

  static List<Tournament> toEntities(List<TournamentDto> dtos) => dtos.map(toEntity).toList();
  static List<TournamentDto> toDtos(List<Tournament> entities) => entities.map(toDto).toList();
}
