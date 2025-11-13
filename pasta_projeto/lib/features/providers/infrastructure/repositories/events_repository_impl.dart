import 'package:lan_party_planner/features/providers/domain/entities/event.dart';
import 'package:lan_party_planner/features/providers/domain/repositories/events_repository.dart';
import 'package:lan_party_planner/features/providers/infrastructure/mappers/event_mapper.dart';
import '../local/events_local_dao_shared_prefs.dart';

class EventsRepositoryImpl implements EventsRepository {
  final EventsLocalDaoSharedPrefs _localDao;

  EventsRepositoryImpl({required EventsLocalDaoSharedPrefs localDao})
      : _localDao = localDao;

  @override
  Future<Event> create(Event event) async {
    try {
      final dto = EventMapper.toDto(event);
      final currentList = await _localDao.listAll();
      currentList.add(dto);
      await _localDao.upsertAll(currentList);
      return event;
    } catch (e) {
      throw Exception('Erro ao criar evento: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      final currentList = await _localDao.listAll();
      currentList.removeWhere((dto) => dto.id == id);
      await _localDao.upsertAll(currentList);
    } catch (e) {
      throw Exception('Erro ao deletar evento: $e');
    }
  }

  @override
  Future<Event?> getById(String id) async {
    try {
      final dto = await _localDao.getById(id);
      return dto != null ? EventMapper.toEntity(dto) : null;
    } catch (e) {
      throw Exception('Erro ao buscar evento: $e');
    }
  }

  @override
  Future<List<Event>> listAll() async {
    try {
      final dtos = await _localDao.listAll();
      return dtos.map((dto) => EventMapper.toEntity(dto)).toList();
    } catch (e) {
      throw Exception('Erro ao listar eventos: $e');
    }
  }

  @override
  Future<Event> update(Event event) async {
    try {
      final dto = EventMapper.toDto(event);
      final currentList = await _localDao.listAll();
      final index = currentList.indexWhere((e) => e.id == event.id);
      if (index >= 0) {
        currentList[index] = dto;
      } else {
        currentList.add(dto);
      }
      await _localDao.upsertAll(currentList);
      return event;
    } catch (e) {
      throw Exception('Erro ao atualizar evento: $e');
    }
  }

  @override
  Future<void> sync() async {
    try {
      // Sincronização local apenas - sem servidor
      // Mantém compatibilidade com a interface
    } catch (e) {
      throw Exception('Erro ao sincronizar eventos: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await _localDao.clear();
    } catch (e) {
      throw Exception('Erro ao limpar cache de eventos: $e');
    }
  }
}
