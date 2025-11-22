import '../entities/participant.dart';

abstract class ParticipantsRepository {
  Future<List<Participant>> listAll();
  Future<Participant?> getById(String id);
  Future<Participant> create(Participant participant);
  Future<Participant> update(Participant participant);
  Future<void> delete(String id);
  Future<void> sync();
  Future<void> clearCache();
}
