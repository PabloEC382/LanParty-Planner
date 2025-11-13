import 'package:lan_party_planner/features/providers/domain/entities/venue.dart';
import 'package:lan_party_planner/features/providers/domain/repositories/venues_repository.dart';
import 'package:lan_party_planner/features/providers/infrastructure/mappers/venue_mapper.dart';
import '../local/venues_local_dao_shared_prefs.dart';

class VenuesRepositoryImpl implements VenuesRepository {
  final VenuesLocalDaoSharedPrefs _localDao;

  VenuesRepositoryImpl({required VenuesLocalDaoSharedPrefs localDao})
      : _localDao = localDao;

  @override
  Future<Venue> create(Venue venue) async {
    try {
      final dto = VenueMapper.toDto(venue);
      final currentList = await _localDao.listAll();
      currentList.add(dto);
      await _localDao.upsertAll(currentList);
      return venue;
    } catch (e) {
      throw Exception('Erro ao criar local: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      final currentList = await _localDao.listAll();
      currentList.removeWhere((dto) => dto.id == id);
      await _localDao.upsertAll(currentList);
    } catch (e) {
      throw Exception('Erro ao deletar local: $e');
    }
  }

  @override
  Future<Venue?> getById(String id) async {
    try {
      final dto = await _localDao.getById(id);
      return dto != null ? VenueMapper.toEntity(dto) : null;
    } catch (e) {
      throw Exception('Erro ao buscar local: $e');
    }
  }

  @override
  Future<List<Venue>> listAll() async {
    try {
      final dtos = await _localDao.listAll();
      return dtos.map((dto) => VenueMapper.toEntity(dto)).toList();
    } catch (e) {
      throw Exception('Erro ao listar locais: $e');
    }
  }

  @override
  Future<Venue> update(Venue venue) async {
    try {
      final dto = VenueMapper.toDto(venue);
      final currentList = await _localDao.listAll();
      final index = currentList.indexWhere((e) => e.id == venue.id);
      if (index >= 0) {
        currentList[index] = dto;
      } else {
        currentList.add(dto);
      }
      await _localDao.upsertAll(currentList);
      return venue;
    } catch (e) {
      throw Exception('Erro ao atualizar local: $e');
    }
  }

  @override
  Future<void> sync() async {
    try {
      // Sincronização local apenas - sem servidor
      // Mantém compatibilidade com a interface
    } catch (e) {
      throw Exception('Erro ao sincronizar locais: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await _localDao.clear();
    } catch (e) {
      throw Exception('Erro ao limpar cache de locais: $e');
    }
  }

  @override
  Future<List<Venue>> findByCity(String city) async {
    try {
      final dtos = await _localDao.listAll();
      final filtered = dtos.where((dto) => dto.city.toLowerCase() == city.toLowerCase()).toList();
      return filtered.map((dto) => VenueMapper.toEntity(dto)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar locais por cidade: $e');
    }
  }

  @override
  Future<List<Venue>> findByState(String state) async {
    try {
      final dtos = await _localDao.listAll();
      final filtered = dtos.where((dto) => dto.state.toLowerCase() == state.toLowerCase()).toList();
      return filtered.map((dto) => VenueMapper.toEntity(dto)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar locais por estado: $e');
    }
  }

  @override
  Future<List<Venue>> findVerified() async {
    try {
      final dtos = await _localDao.listAll();
      final filtered = dtos.where((dto) => dto.is_verified).toList();
      return filtered.map((dto) => VenueMapper.toEntity(dto)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar locais verificados: $e');
    }
  }

  @override
  Future<List<Venue>> findByMinCapacity(int minCapacity) async {
    try {
      final dtos = await _localDao.listAll();
      final filtered = dtos.where((dto) => dto.capacity >= minCapacity).toList();
      return filtered.map((dto) => VenueMapper.toEntity(dto)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar locais por capacidade: $e');
    }
  }

  @override
  Future<List<Venue>> findTopRated({int limit = 10}) async {
    try {
      final dtos = await _localDao.listAll();
      final sorted = List<dynamic>.from(dtos);
      sorted.sort((a, b) => (b.rating as double).compareTo(a.rating as double));
      final topRated = sorted.take(limit).toList();
      return topRated.map((dto) => VenueMapper.toEntity(dto as dynamic)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar locais melhor avaliados: $e');
    }
  }
}
