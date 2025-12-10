import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/participant.dart';
import '../../domain/repositories/participants_repository.dart';
import '../mappers/participant_mapper.dart';
import '../local/participants_local_dao_shared_prefs.dart';
import '../remote/participants_remote_api.dart';

/// Implementação concreta do [ParticipantsRepository] usando estratégia de cache local com sincronização remota.
class ParticipantsRepositoryImpl implements ParticipantsRepository {
  static const String _lastSyncKeyV1 = 'participants_last_sync_v1';

  final ParticipantsRemoteApi _remoteApi;
  final ParticipantsLocalDaoSharedPrefs _localDao;
  late final Future<SharedPreferences> _prefs;

  ParticipantsRepositoryImpl({
    required ParticipantsRemoteApi remoteApi,
    required ParticipantsLocalDaoSharedPrefs localDao,
  })  : _remoteApi = remoteApi,
        _localDao = localDao {
    _prefs = SharedPreferences.getInstance();
  }

  @override
  Future<List<Participant>> loadFromCache() async {
    try {
      if (kDebugMode) {
        developer.log(
          'ParticipantsRepositoryImpl.loadFromCache: carregando do cache',
          name: 'ParticipantsRepositoryImpl',
        );
      }
      final dtos = await _localDao.listAll();
      return dtos.map((dto) => ParticipantMapper.toEntity(dto)).toList();
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro ao carregar cache de participants: $e',
          name: 'ParticipantsRepositoryImpl',
          error: e,
        );
      }
      return [];
    }
  }

  @override
  Future<int> syncFromServer() async {
    try {
      if (kDebugMode) {
        developer.log(
          'ParticipantsRepositoryImpl.syncFromServer: iniciando sincronização (push então pull)',
          name: 'ParticipantsRepositoryImpl',
        );
      }

      // ===== ETAPA 1: PUSH =====
      // Comentário: Enviar dados locais para o servidor (melhor esforço)
      try {
        final localDtos = await _localDao.listAll();
        if (localDtos.isNotEmpty) {
          final pushed = await _remoteApi.upsertParticipants(localDtos);
          if (kDebugMode) {
            developer.log(
              'ParticipantsRepositoryImpl.syncFromServer: pushed $pushed items ao remoto',
              name: 'ParticipantsRepositoryImpl',
            );
          }
        }
      } catch (pushError) {
        // Comentário: Falha de push não bloqueia o pull
        if (kDebugMode) {
          developer.log(
            'ParticipantsRepositoryImpl.syncFromServer: erro ao fazer push (continuando com pull): $pushError',
            name: 'ParticipantsRepositoryImpl',
            error: pushError,
          );
        }
      }

      // ===== ETAPA 2: PULL =====
      final prefs = await _prefs;
      final lastSyncIso = prefs.getString(_lastSyncKeyV1);
      DateTime? since;
      if (lastSyncIso != null && lastSyncIso.isNotEmpty) {
        try {
          since = DateTime.parse(lastSyncIso);
        } catch (e) {
          if (kDebugMode) {
            developer.log(
              'Erro ao parsear lastSync de participants: $e',
              name: 'ParticipantsRepositoryImpl',
              error: e,
            );
          }
        }
      }
      final page = await _remoteApi.fetchParticipants(since: since, limit: 500);
      if (page.isEmpty) {
        return 0;
      }
      await _localDao.upsertAll(page.items);
      final newestUpdatedAt = _computeNewestUpdatedAt(page.items);
      await prefs.setString(_lastSyncKeyV1, newestUpdatedAt.toIso8601String());
      if (kDebugMode) {
        developer.log(
          'ParticipantsRepositoryImpl.syncFromServer: ${page.items.length} participants sincronizados',
          name: 'ParticipantsRepositoryImpl',
        );
      }
      return page.items.length;
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro ao sincronizar participants: $e',
          name: 'ParticipantsRepositoryImpl',
          error: e,
        );
      }
      return 0;
    }
  }

  @override
  Future<List<Participant>> listAll() async {
    try {
      if (kDebugMode) {
        developer.log(
          'ParticipantsRepositoryImpl.listAll: listando todos os participants',
          name: 'ParticipantsRepositoryImpl',
        );
      }
      final dtos = await _localDao.listAll();
      return dtos.map((dto) => ParticipantMapper.toEntity(dto)).toList();
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro ao listar participants: $e',
          name: 'ParticipantsRepositoryImpl',
          error: e,
        );
      }
      return [];
    }
  }

  @override
  Future<List<Participant>> listFeatured() async {
    try {
      if (kDebugMode) {
        developer.log(
          'ParticipantsRepositoryImpl.listFeatured: listando participants em destaque',
          name: 'ParticipantsRepositoryImpl',
        );
      }
      final dtos = await _localDao.listAll();
      final featured = dtos.where((dto) => dto.is_premium || dto.skill_level >= 8).toList();
      return featured.map((dto) => ParticipantMapper.toEntity(dto)).toList();
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro ao listar participants em destaque: $e',
          name: 'ParticipantsRepositoryImpl',
          error: e,
        );
      }
      return [];
    }
  }

  @override
  Future<Participant?> getById(int id) async {
    try {
      if (kDebugMode) {
        developer.log(
          'ParticipantsRepositoryImpl.getById: buscando participant com id=$id',
          name: 'ParticipantsRepositoryImpl',
        );
      }
      final dto = await _localDao.getById(id.toString());
      return dto != null ? ParticipantMapper.toEntity(dto) : null;
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro ao buscar participant por id: $e',
          name: 'ParticipantsRepositoryImpl',
          error: e,
        );
      }
      return null;
    }
  }

  DateTime _computeNewestUpdatedAt(List<dynamic> items) {
    if (items.isEmpty) {
      return DateTime.now().toUtc();
    }
    DateTime newest = DateTime.parse(items[0].updated_at as String);
    for (final item in items) {
      try {
        final itemDate = DateTime.parse(item.updated_at as String);
        if (itemDate.isAfter(newest)) {
          newest = itemDate;
        }
      } catch (_) {}
    }
    return newest;
  }

  Future<Participant> createParticipant(Participant participant) async {
    try {
      final dto = ParticipantMapper.toDto(participant);
      final createdDto = await _remoteApi.createParticipant(dto);
      await _localDao.upsertAll([createdDto]);
      if (kDebugMode) {
        developer.log('ParticipantsRepositoryImpl.createParticipant: criado ${participant.id}', name: 'ParticipantsRepositoryImpl');
      }
      return ParticipantMapper.toEntity(createdDto);
    } catch (e) {
      if (kDebugMode) {
        developer.log('Erro ao criar participant: $e', name: 'ParticipantsRepositoryImpl', error: e);
      }
      rethrow;
    }
  }

  Future<Participant> updateParticipant(Participant participant) async {
    try {
      final dto = ParticipantMapper.toDto(participant);
      final updatedDto = await _remoteApi.updateParticipant(participant.id, dto);
      await _localDao.upsertAll([updatedDto]);
      if (kDebugMode) {
        developer.log('ParticipantsRepositoryImpl.updateParticipant: atualizado ${participant.id}', name: 'ParticipantsRepositoryImpl');
      }
      return ParticipantMapper.toEntity(updatedDto);
    } catch (e) {
      if (kDebugMode) {
        developer.log('Erro ao atualizar participant: $e', name: 'ParticipantsRepositoryImpl', error: e);
      }
      rethrow;
    }
  }

  Future<void> deleteParticipant(String id) async {
    try {
      await _remoteApi.deleteParticipant(id);
      final allParticipants = await _localDao.listAll();
      final filtered = allParticipants.where((dto) => dto.id != id).toList();
      await _localDao.clear();
      if (filtered.isNotEmpty) {
        await _localDao.upsertAll(filtered);
      }
      if (kDebugMode) {
        developer.log('ParticipantsRepositoryImpl.deleteParticipant: deletado $id', name: 'ParticipantsRepositoryImpl');
      }
    } catch (e) {
      if (kDebugMode) {
        developer.log('Erro ao deletar participant: $e', name: 'ParticipantsRepositoryImpl', error: e);
      }
      rethrow;
    }
  }
}
