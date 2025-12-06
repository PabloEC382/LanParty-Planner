import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/venue.dart';
import '../../domain/repositories/venues_repository.dart';
import '../mappers/venue_mapper.dart';
import '../local/venues_local_dao_shared_prefs.dart';
import '../remote/venues_remote_api.dart';

/// Implementação concreta do [VenuesRepository] usando estratégia de cache local com sincronização remota.
class VenuesRepositoryImpl implements VenuesRepository {
  static const String _lastSyncKeyV1 = 'venues_last_sync_v1';

  final VenuesRemoteApi _remoteApi;
  final VenuesLocalDaoSharedPrefs _localDao;
  late final Future<SharedPreferences> _prefs;

  VenuesRepositoryImpl({
    required VenuesRemoteApi remoteApi,
    required VenuesLocalDaoSharedPrefs localDao,
  })  : _remoteApi = remoteApi,
        _localDao = localDao {
    _prefs = SharedPreferences.getInstance();
  }

  @override
  Future<List<Venue>> loadFromCache() async {
    try {
      if (kDebugMode) {
        developer.log(
          'VenuesRepositoryImpl.loadFromCache: carregando do cache',
          name: 'VenuesRepositoryImpl',
        );
      }
      final dtos = await _localDao.listAll();
      return dtos.map((dto) => VenueMapper.toEntity(dto)).toList();
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro ao carregar cache de venues: $e',
          name: 'VenuesRepositoryImpl',
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
          'VenuesRepositoryImpl.syncFromServer: iniciando sincronização (push então pull)',
          name: 'VenuesRepositoryImpl',
        );
      }

      // ===== ETAPA 1: PUSH =====
      // Comentário: Enviar dados locais para o servidor (melhor esforço)
      try {
        final localDtos = await _localDao.listAll();
        if (localDtos.isNotEmpty) {
          final pushed = await _remoteApi.upsertVenues(localDtos);
          if (kDebugMode) {
            developer.log(
              'VenuesRepositoryImpl.syncFromServer: pushed $pushed items ao remoto',
              name: 'VenuesRepositoryImpl',
            );
          }
        }
      } catch (pushError) {
        // Comentário: Falha de push não bloqueia o pull
        if (kDebugMode) {
          developer.log(
            'VenuesRepositoryImpl.syncFromServer: erro ao fazer push (continuando com pull): $pushError',
            name: 'VenuesRepositoryImpl',
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
              'Erro ao parsear lastSync de venues: $e',
              name: 'VenuesRepositoryImpl',
              error: e,
            );
          }
        }
      }
      final page = await _remoteApi.fetchVenues(since: since, limit: 500);
      if (page.isEmpty) {
        return 0;
      }
      await _localDao.upsertAll(page.items);
      final newestUpdatedAt = _computeNewestUpdatedAt(page.items);
      await prefs.setString(_lastSyncKeyV1, newestUpdatedAt.toIso8601String());
      if (kDebugMode) {
        developer.log(
          'VenuesRepositoryImpl.syncFromServer: ${page.items.length} venues sincronizados',
          name: 'VenuesRepositoryImpl',
        );
      }
      return page.items.length;
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro ao sincronizar venues: $e',
          name: 'VenuesRepositoryImpl',
          error: e,
        );
      }
      return 0;
    }
  }

  @override
  Future<List<Venue>> listAll() async {
    try {
      if (kDebugMode) {
        developer.log(
          'VenuesRepositoryImpl.listAll: listando todos os venues',
          name: 'VenuesRepositoryImpl',
        );
      }
      final dtos = await _localDao.listAll();
      return dtos.map((dto) => VenueMapper.toEntity(dto)).toList();
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro ao listar venues: $e',
          name: 'VenuesRepositoryImpl',
          error: e,
        );
      }
      return [];
    }
  }

  @override
  Future<List<Venue>> listFeatured() async {
    try {
      if (kDebugMode) {
        developer.log(
          'VenuesRepositoryImpl.listFeatured: listando venues em destaque',
          name: 'VenuesRepositoryImpl',
        );
      }
      final dtos = await _localDao.listAll();
      final featured = dtos.where((dto) => dto.rating >= 4.0).toList();
      return featured.map((dto) => VenueMapper.toEntity(dto)).toList();
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro ao listar venues em destaque: $e',
          name: 'VenuesRepositoryImpl',
          error: e,
        );
      }
      return [];
    }
  }

  @override
  Future<Venue?> getById(int id) async {
    try {
      if (kDebugMode) {
        developer.log(
          'VenuesRepositoryImpl.getById: buscando venue com id=$id',
          name: 'VenuesRepositoryImpl',
        );
      }
      final dto = await _localDao.getById(id.toString());
      return dto != null ? VenueMapper.toEntity(dto) : null;
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro ao buscar venue por id: $e',
          name: 'VenuesRepositoryImpl',
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
}
