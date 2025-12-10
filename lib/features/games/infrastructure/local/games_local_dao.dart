import '../dtos/game_dto.dart';

abstract class GamesLocalDao {
  Future<void> upsertAll(List<GameDto> dtos);
  Future<void> clear();
  Future<GameDto?> getById(String id);
  Future<List<GameDto>> listAll();
}
