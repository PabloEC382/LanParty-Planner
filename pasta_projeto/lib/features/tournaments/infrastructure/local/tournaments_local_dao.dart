import '../dtos/tournament_dto.dart';

abstract class TournamentsLocalDao {
  Future<void> upsertAll(List<TournamentDto> dtos);
  Future<void> clear();
  Future<TournamentDto?> getById(String id);
  Future<List<TournamentDto>> listAll();
}
