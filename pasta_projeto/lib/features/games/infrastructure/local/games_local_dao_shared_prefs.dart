import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'games_local_dao.dart';
import '../dtos/game_dto.dart';

class GamesLocalDaoSharedPrefs implements GamesLocalDao {
  static const _cacheKey = 'games_cache_v1';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  @override
  Future<void> upsertAll(List<GameDto> dtos) async {
    final prefs = await _prefs;
    final raw = prefs.getString(_cacheKey);
    final Map<String, Map<String, dynamic>> current = {};

    if (raw != null && raw.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
        for (final e in list) {
          final m = Map<String, dynamic>.from(e as Map);
          current[m['id'] as String] = m;
        }
      } catch (_) {}
    }

    for (final dto in dtos) {
      current[dto.id] = dto.toMap();
    }

    final merged = current.values.toList();
    await prefs.setString(_cacheKey, jsonEncode(merged));
  }

  @override
  Future<void> clear() async {
    final prefs = await _prefs;
    await prefs.remove(_cacheKey);
  }

  @override
  Future<GameDto?> getById(String id) async {
    final prefs = await _prefs;
    final raw = prefs.getString(_cacheKey);
    if (raw == null || raw.isEmpty) return null;

    try {
      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      for (final e in list) {
        final m = Map<String, dynamic>.from(e as Map);
        if (m['id'] == id) return GameDto.fromMap(m);
      }
    } catch (_) {}

    return null;
  }

  @override
  Future<List<GameDto>> listAll() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_cacheKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => GameDto.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
