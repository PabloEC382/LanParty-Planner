import '../entities/tournament.dart';

abstract class TournamentsRepository {
  Future<List<Tournament>> listAll();
  Future<Tournament?> getById(String id);
  Future<Tournament> create(Tournament tournament);
  Future<Tournament> update(Tournament tournament);
  Future<void> delete(String id);
  Future<void> sync();
  Future<void> clearCache();
}
