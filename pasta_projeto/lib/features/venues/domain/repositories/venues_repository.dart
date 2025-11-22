import '../entities/venue.dart';

abstract class VenuesRepository {
  Future<List<Venue>> listAll();
  Future<Venue?> getById(String id);
  Future<Venue> create(Venue venue);
  Future<Venue> update(Venue venue);
  Future<void> delete(String id);
  Future<void> sync();
  Future<void> clearCache();
}
