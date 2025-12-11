import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/event.dart';
import '../../domain/repositories/events_repository.dart';
import '../mappers/event_mapper.dart';
import '../local/events_local_dao_shared_prefs.dart';
import '../remote/events_remote_api.dart';

class EventsRepositoryImpl implements EventsRepository {
  static const String _lastSyncKeyV1 = 'events_last_sync_v1';

  final EventsRemoteApi _remoteApi;
  final EventsLocalDaoSharedPrefs _localDao;
  late final Future<SharedPreferences> _prefs;

  EventsRepositoryImpl({
    required EventsRemoteApi remoteApi,
    required EventsLocalDaoSharedPrefs localDao,
  }) : _remoteApi = remoteApi,
       _localDao = localDao {
    _prefs = SharedPreferences.getInstance();
  }

  @override
  Future<List<Event>> loadFromCache() async {
    try {
      if (kDebugMode) {
        developer.log(
          'EventsRepositoryImpl.loadFromCache: carregando do cache',
          name: 'EventsRepositoryImpl',
        );
      }
      final dtos = await _localDao.listAll();
      return dtos.map((dto) => EventMapper.toEntity(dto)).toList();
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro ao carregar cache de events: $e',
          name: 'EventsRepositoryImpl',
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
          'EventsRepositoryImpl.syncFromServer: iniciando sincronização (push então pull)',
          name: 'EventsRepositoryImpl',
        );
      }

      // ===== ETAPA 1: PUSH =====
      // Comentário: Enviar dados locais para o servidor (melhor esforço)
      try {
        final localDtos = await _localDao.listAll();
        if (localDtos.isNotEmpty) {
          final pushed = await _remoteApi.upsertEvents(localDtos);
          if (kDebugMode) {
            developer.log(
              'EventsRepositoryImpl.syncFromServer: pushed $pushed items ao remoto',
              name: 'EventsRepositoryImpl',
            );
          }
        }
      } catch (pushError) {
        // Comentário: Falha de push não bloqueia o pull
        if (kDebugMode) {
          developer.log(
            'EventsRepositoryImpl.syncFromServer: erro ao fazer push (continuando com pull): $pushError',
            name: 'EventsRepositoryImpl',
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
              'Erro ao parsear lastSync de events: $e',
              name: 'EventsRepositoryImpl',
              error: e,
            );
          }
        }
      }
      if (kDebugMode) {
        developer.log(
          'EventsRepositoryImpl.syncFromServer: buscando events no servidor (since=$since)',
          name: 'EventsRepositoryImpl',
        );
      }
      final page = await _remoteApi.fetchEvents(since: since, limit: 500);
      if (kDebugMode) {
        developer.log(
          'EventsRepositoryImpl.syncFromServer: página recebida com ${page.items.length} items, isEmpty=${page.isEmpty}',
          name: 'EventsRepositoryImpl',
        );
      }
      if (page.isEmpty) {
        if (kDebugMode) {
          developer.log(
            'EventsRepositoryImpl.syncFromServer: nenhum evento retornado do servidor',
            name: 'EventsRepositoryImpl',
          );
        }
        return 0;
      }
      await _localDao.upsertAll(page.items);
      final newestUpdatedAt = _computeNewestUpdatedAt(page.items);
      await prefs.setString(_lastSyncKeyV1, newestUpdatedAt.toIso8601String());
      if (kDebugMode) {
        developer.log(
          'EventsRepositoryImpl.syncFromServer: ${page.items.length} events sincronizados, lastSync atualizado para $newestUpdatedAt',
          name: 'EventsRepositoryImpl',
        );
      }
      return page.items.length;
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro ao sincronizar events: $e',
          name: 'EventsRepositoryImpl',
          error: e,
        );
      }
      return 0;
    }
  }

  @override
  Future<List<Event>> listAll() async {
    try {
      if (kDebugMode) {
        developer.log(
          'EventsRepositoryImpl.listAll: listando todos os events',
          name: 'EventsRepositoryImpl',
        );
      }
      final dtos = await _localDao.listAll();
      return dtos.map((dto) => EventMapper.toEntity(dto)).toList();
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro ao listar events: $e',
          name: 'EventsRepositoryImpl',
          error: e,
        );
      }
      return [];
    }
  }

  @override
  Future<List<Event>> listFeatured() async {
    try {
      if (kDebugMode) {
        developer.log(
          'EventsRepositoryImpl.listFeatured: listando events em destaque',
          name: 'EventsRepositoryImpl',
        );
      }
      final dtos = await _localDao.listAll();
      final featured = dtos
          .where((dto) => dto.state == 'published' || dto.state == 'ongoing')
          .toList();
      return featured.map((dto) => EventMapper.toEntity(dto)).toList();
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro ao listar events em destaque: $e',
          name: 'EventsRepositoryImpl',
          error: e,
        );
      }
      return [];
    }
  }

  @override
  Future<Event?> getById(int id) async {
    try {
      if (kDebugMode) {
        developer.log(
          'EventsRepositoryImpl.getById: buscando event com id=$id',
          name: 'EventsRepositoryImpl',
        );
      }
      final dto = await _localDao.getById(id.toString());
      return dto != null ? EventMapper.toEntity(dto) : null;
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro ao buscar event por id: $e',
          name: 'EventsRepositoryImpl',
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

  Future<Event> createEvent(Event event) async {
    try {
      final dto = EventMapper.toDto(event);
      final createdDto = await _remoteApi.createEvent(dto);
      await _localDao.upsertAll([createdDto]);
      if (kDebugMode) {
        developer.log(
          'EventsRepositoryImpl.createEvent: criado ${event.id}',
          name: 'EventsRepositoryImpl',
        );
      }
      return EventMapper.toEntity(createdDto);
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro ao criar event: $e',
          name: 'EventsRepositoryImpl',
          error: e,
        );
      }
      rethrow;
    }
  }

  Future<Event> updateEvent(Event event) async {
    try {
      final dto = EventMapper.toDto(event);
      final updatedDto = await _remoteApi.updateEvent(event.id, dto);
      await _localDao.upsertAll([updatedDto]);
      if (kDebugMode) {
        developer.log(
          'EventsRepositoryImpl.updateEvent: atualizado ${event.id}',
          name: 'EventsRepositoryImpl',
        );
      }
      return EventMapper.toEntity(updatedDto);
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro ao atualizar event: $e',
          name: 'EventsRepositoryImpl',
          error: e,
        );
      }
      rethrow;
    }
  }

  Future<void> deleteEvent(String id) async {
    try {
      await _remoteApi.deleteEvent(id);
      final allEvents = await _localDao.listAll();
      final filtered = allEvents.where((dto) => dto.id != id).toList();
      await _localDao.clear();
      if (filtered.isNotEmpty) {
        await _localDao.upsertAll(filtered);
      }
      if (kDebugMode) {
        developer.log(
          'EventsRepositoryImpl.deleteEvent: deletado $id',
          name: 'EventsRepositoryImpl',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro ao deletar event: $e',
          name: 'EventsRepositoryImpl',
          error: e,
        );
      }
      rethrow;
    }
  }
}
