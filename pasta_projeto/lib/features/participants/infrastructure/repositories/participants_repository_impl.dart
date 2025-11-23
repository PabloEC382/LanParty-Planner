import '../../domain/entities/participant.dart';
import '../../domain/repositories/participants_repository.dart';
import '../mappers/participant_mapper.dart';
import '../local/participants_local_dao_shared_prefs.dart';

class ParticipantsRepositoryImpl implements ParticipantsRepository {
  final ParticipantsLocalDaoSharedPrefs _localDao;

  ParticipantsRepositoryImpl({required ParticipantsLocalDaoSharedPrefs localDao})
      : _localDao = localDao;

  @override
  Future<Participant> create(Participant participant) async {
    try {
      final dto = ParticipantMapper.toDto(participant);
      final currentList = await _localDao.listAll();
      currentList.add(dto);
      await _localDao.upsertAll(currentList);
      return participant;
    } catch (e) {
      throw Exception('Erro ao criar participante: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      final currentList = await _localDao.listAll();
      currentList.removeWhere((dto) => dto.id == id);
      await _localDao.upsertAll(currentList);
    } catch (e) {
      throw Exception('Erro ao deletar participante: $e');
    }
  }

  @override
  Future<Participant?> getById(String id) async {
    try {
      final dto = await _localDao.getById(id);
      return dto != null ? ParticipantMapper.toEntity(dto) : null;
    } catch (e) {
      throw Exception('Erro ao buscar participante: $e');
    }
  }

  Future<Participant?> getByEmail(String email) async {
    try {
      final dtos = await _localDao.listAll();
      final dto = dtos.firstWhere(
        (p) => p.email.toLowerCase() == email.toLowerCase(),
        orElse: () => throw Exception('Participante não encontrado'),
      );
      return ParticipantMapper.toEntity(dto);
    } catch (e) {
      return null;
    }
  }

  Future<Participant?> getByNickname(String nickname) async {
    try {
      final dtos = await _localDao.listAll();
      final dto = dtos.firstWhere(
        (p) => p.nickname.toLowerCase() == nickname.toLowerCase(),
        orElse: () => throw Exception('Participante não encontrado'),
      );
      return ParticipantMapper.toEntity(dto);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Participant>> listAll() async {
    try {
      final dtos = await _localDao.listAll();
      return dtos.map((dto) => ParticipantMapper.toEntity(dto)).toList();
    } catch (e) {
      throw Exception('Erro ao listar participantes: $e');
    }
  }

  @override
  Future<Participant> update(Participant participant) async {
    try {
      final dto = ParticipantMapper.toDto(participant);
      final currentList = await _localDao.listAll();
      final index = currentList.indexWhere((e) => e.id == participant.id);
      if (index >= 0) {
        currentList[index] = dto;
      } else {
        currentList.add(dto);
      }
      await _localDao.upsertAll(currentList);
      return participant;
    } catch (e) {
      throw Exception('Erro ao atualizar participante: $e');
    }
  }

  @override
  Future<void> sync() async {
    try {
      // Sincronização local apenas - sem servidor
      // Mantém compatibilidade com a interface
    } catch (e) {
      throw Exception('Erro ao sincronizar participantes: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await _localDao.clear();
    } catch (e) {
      throw Exception('Erro ao limpar cache de participantes: $e');
    }
  }

  Future<List<Participant>> findPremium() async {
    try {
      final dtos = await _localDao.listAll();
      final filtered = dtos.where((dto) => dto.is_premium).toList();
      return filtered.map((dto) => ParticipantMapper.toEntity(dto)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar participantes premium: $e');
    }
  }

  Future<List<Participant>> findBySkillLevel(int skillLevel) async {
    try {
      final dtos = await _localDao.listAll();
      final filtered = dtos.where((dto) => dto.skill_level == skillLevel).toList();
      return filtered.map((dto) => ParticipantMapper.toEntity(dto)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar participantes por nível: $e');
    }
  }
}
