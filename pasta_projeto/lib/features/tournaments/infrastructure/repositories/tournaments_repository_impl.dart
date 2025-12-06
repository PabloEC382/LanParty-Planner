import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/tournament.dart';
import '../../domain/repositories/tournaments_repository.dart';
import '../mappers/tournament_mapper.dart';
import '../local/tournaments_local_dao_shared_prefs.dart';
import '../remote/tournaments_remote_api.dart';

/// Implementação concreta do [TournamentsRepository] usando estratégia de cache local com sincronização remota.
class TournamentsRepositoryImpl implements TournamentsRepository {
  static const String _lastSyncKeyV1 = 'tournaments_last_sync_v1';

  final TournamentsRemoteApi _remoteApi;
  final TournamentsLocalDaoSharedPrefs _localDao;
  late final Future<SharedPreferences> _prefs;

  TournamentsRepositoryImpl({
    required TournamentsRemoteApi remoteApi,
    required TournamentsLocalDaoSharedPrefs localDao,
  })  : _remoteApi = remoteApi,
        _localDao = localDao {
    _prefs = SharedPreferences.getInstance();
  }

  @override
  Future<List<Tournament>> loadFromCache() async {
    try {
      if (kDebugMode) {
        developer.log(
          'TournamentsRepositoryImpl.loadFromCache: carregando do cache',
          name: 'TournamentsRepositoryImpl',
        );
      }
      final dtos = await _localDao.listAll();
      return dtos.map((dto) => TournamentMapper.toEntity(dto)).toList();
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro ao carregar cache de tournaments: $e',
          name: 'TournamentsRepositoryImpl',
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
          'TournamentsRepositoryImpl.syncFromServer: iniciando sincronização (push então pull)',
          name: 'TournamentsRepositoryImpl',
        );
      }

      // ===== ETAPA 1: PUSH =====
      // Comentário: Enviar dados locais para o servidor (melhor esforço)
      try {
        final localDtos = await _localDao.listAll();
        if (localDtos.isNotEmpty) {
          final pushed = await _remoteApi.upsertTournaments(localDtos);
          if (kDebugMode) {
            developer.log(
              'TournamentsRepositoryImpl.syncFromServer: pushed $pushed items ao remoto',
              name: 'TournamentsRepositoryImpl',
            );
          }
        }
      } catch (pushError) {
        // Comentário: Falha de push não bloqueia o pull
        if (kDebugMode) {
          developer.log(
            'TournamentsRepositoryImpl.syncFromServer: erro ao fazer push (continuando com pull): $pushError',
            name: 'TournamentsRepositoryImpl',
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
              'Erro ao parsear lastSync de tournaments: $e',
              name: 'TournamentsRepositoryImpl',
              error: e,
            );
          }
        }
      }
      final page = await _remoteApi.fetchTournaments(since: since, limit: 500);
      if (page.isEmpty) {
        return 0;
      }
      await _localDao.upsertAll(page.items);
      final newestUpdatedAt = _computeNewestUpdatedAt(page.items);
      await prefs.setString(_lastSyncKeyV1, newestUpdatedAt.toIso8601String());
      if (kDebugMode) {
        developer.log(
          'TournamentsRepositoryImpl.syncFromServer: ${page.items.length} tournaments sincronizados',
          name: 'TournamentsRepositoryImpl',
        );
      }
      return page.items.length;
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro ao sincronizar tournaments: $e',
          name: 'TournamentsRepositoryImpl',
          error: e,
        );
      }
      return 0;
    }
  }

  @override
  Future<List<Tournament>> listAll() async {
    try {
      if (kDebugMode) {
        developer.log(
          'TournamentsRepositoryImpl.listAll: listando todos os tournaments',
          name: 'TournamentsRepositoryImpl',
        );
      }
      final dtos = await _localDao.listAll();
      return dtos.map((dto) => TournamentMapper.toEntity(dto)).toList();
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro ao listar tournaments: $e',
          name: 'TournamentsRepositoryImpl',
          error: e,
        );
      }
      return [];
    }
  }

  @override
  Future<List<Tournament>> listFeatured() async {
    try {
      if (kDebugMode) {
        developer.log(
          'TournamentsRepositoryImpl.listFeatured: listando tournaments em destaque',
          name: 'TournamentsRepositoryImpl',
        );
      }
      final dtos = await _localDao.listAll();
      final featured = dtos.where((dto) {
        // Filtrar por status registration ou in_progress como "featured"
        return dto.status.toLowerCase() == 'registration' || dto.status.toLowerCase() == 'in_progress';
      }).toList();
      return featured.map((dto) => TournamentMapper.toEntity(dto)).toList();
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro ao listar tournaments em destaque: $e',
          name: 'TournamentsRepositoryImpl',
          error: e,
        );
      }
      return [];
    }
  }

  @override
  Future<Tournament?> getById(int id) async {
    try {
      if (kDebugMode) {
        developer.log(
          'TournamentsRepositoryImpl.getById: buscando tournament com id=$id',
          name: 'TournamentsRepositoryImpl',
        );
      }
      final dto = await _localDao.getById(id.toString());
      return dto != null ? TournamentMapper.toEntity(dto) : null;
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro ao buscar tournament por id: $e',
          name: 'TournamentsRepositoryImpl',
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
