import '../dtos/participant_dto.dart';

abstract class ParticipantsLocalDao {
  Future<void> upsertAll(List<ParticipantDto> dtos);
  Future<void> clear();
  Future<ParticipantDto?> getById(String id);
  Future<List<ParticipantDto>> listAll();
}
