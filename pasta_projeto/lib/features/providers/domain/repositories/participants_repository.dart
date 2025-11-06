import '../entities/participant.dart';

abstract class ParticipantsRepository {
  /// Lista todos os participantes
  Future<List<Participant>> listAll();

  /// Busca um participante por ID
  Future<Participant?> getById(String id);

  /// Busca um participante por email
  Future<Participant?> getByEmail(String email);

  /// Busca um participante por nickname
  Future<Participant?> getByNickname(String nickname);

  /// Cria um novo participante
  Future<Participant> create(Participant participant);

  /// Atualiza um participante existente
  Future<Participant> update(Participant participant);

  /// Deleta um participante por ID
  Future<void> delete(String id);

  /// Busca participantes premium
  Future<List<Participant>> findPremium();

  /// Busca participantes por nível de habilidade
  Future<List<Participant>> findBySkillLevel(int skillLevel);

  /// Sincroniza participantes locais com o servidor
  Future<void> sync();

  /// Limpa o cache local
  Future<void> clearCache();
}
