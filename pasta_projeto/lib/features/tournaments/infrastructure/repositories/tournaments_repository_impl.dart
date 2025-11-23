import '../../domain/entities/tournament.dart';
import '../../domain/repositories/tournaments_repository.dart';
import '../mappers/tournament_mapper.dart';
import '../local/tournaments_local_dao_shared_prefs.dart';

class TournamentsRepositoryImpl implements TournamentsRepository {
  final TournamentsLocalDaoSharedPrefs _localDao;

  TournamentsRepositoryImpl({required TournamentsLocalDaoSharedPrefs localDao})
      : _localDao = localDao;

  @override
  Future<Tournament> create(Tournament tournament) async {
    try {
      final dto = TournamentMapper.toDto(tournament);
      final currentList = await _localDao.listAll();
      currentList.add(dto);
      await _localDao.upsertAll(currentList);
      return tournament;
    } catch (e) {
      throw Exception('Erro ao criar torneio: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      final currentList = await _localDao.listAll();
      currentList.removeWhere((dto) => dto.id == id);
      await _localDao.upsertAll(currentList);
    } catch (e) {
      throw Exception('Erro ao deletar torneio: $e');
    }
  }

  @override
  Future<Tournament?> getById(String id) async {
    try {
      final dto = await _localDao.getById(id);
      return dto != null ? TournamentMapper.toEntity(dto) : null;
    } catch (e) {
      throw Exception('Erro ao buscar torneio: $e');
    }
  }

  @override
  Future<List<Tournament>> listAll() async {
    try {
      final dtos = await _localDao.listAll();
      return dtos.map((dto) => TournamentMapper.toEntity(dto)).toList();
    } catch (e) {
      throw Exception('Erro ao listar torneios: $e');
    }
  }

  @override
  Future<Tournament> update(Tournament tournament) async {
    try {
      final dto = TournamentMapper.toDto(tournament);
      final currentList = await _localDao.listAll();
      final index = currentList.indexWhere((e) => e.id == tournament.id);
      if (index >= 0) {
        currentList[index] = dto;
      } else {
        currentList.add(dto);
      }
      await _localDao.upsertAll(currentList);
      return tournament;
    } catch (e) {
      throw Exception('Erro ao atualizar torneio: $e');
    }
  }

  @override
  Future<void> sync() async {
    try {
      // Sincronização local apenas - sem servidor
      // Mantém compatibilidade com a interface
    } catch (e) {
      throw Exception('Erro ao sincronizar torneios: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await _localDao.clear();
    } catch (e) {
      throw Exception('Erro ao limpar cache de torneios: $e');
    }
  }

  Future<List<Tournament>> findByStatus(TournamentStatus status) async {
    try {
      final dtos = await _localDao.listAll();
      final statusStr = _statusToString(status);
      final filtered = dtos.where((dto) => dto.status.toLowerCase() == statusStr.toLowerCase()).toList();
      return filtered.map((dto) => TournamentMapper.toEntity(dto)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar torneios por status: $e');
    }
  }

  Future<List<Tournament>> findByGame(String gameId) async {
    try {
      final dtos = await _localDao.listAll();
      final filtered = dtos.where((dto) => dto.game_id == gameId).toList();
      return filtered.map((dto) => TournamentMapper.toEntity(dto)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar torneios por jogo: $e');
    }
  }

  Future<List<Tournament>> findOpenForRegistration() async {
    try {
      final dtos = await _localDao.listAll();
      final filtered = dtos.where((dto) => dto.status.toLowerCase() == 'registration').toList();
      return filtered.map((dto) => TournamentMapper.toEntity(dto)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar torneios abertos: $e');
    }
  }

  Future<List<Tournament>> findInProgress() async {
    try {
      final dtos = await _localDao.listAll();
      final filtered = dtos.where((dto) => dto.status.toLowerCase() == 'in_progress').toList();
      return filtered.map((dto) => TournamentMapper.toEntity(dto)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar torneios em andamento: $e');
    }
  }

  String _statusToString(TournamentStatus status) {
    switch (status) {
      case TournamentStatus.draft: return 'draft';
      case TournamentStatus.registration: return 'registration';
      case TournamentStatus.inProgress: return 'in_progress';
      case TournamentStatus.finished: return 'finished';
      case TournamentStatus.cancelled: return 'cancelled';
    }
  }
}
