import '../entities/venue.dart';

abstract class VenuesRepository {
  /// Lista todos os locais
  Future<List<Venue>> listAll();

  /// Busca um local por ID
  Future<Venue?> getById(String id);

  /// Cria um novo local
  Future<Venue> create(Venue venue);

  /// Atualiza um local existente
  Future<Venue> update(Venue venue);

  /// Deleta um local por ID
  Future<void> delete(String id);

  /// Busca locais por cidade
  Future<List<Venue>> findByCity(String city);

  /// Busca locais por estado
  Future<List<Venue>> findByState(String state);

  /// Busca locais verificados
  Future<List<Venue>> findVerified();

  /// Busca locais por capacidade mínima
  Future<List<Venue>> findByMinCapacity(int minCapacity);

  /// Busca locais ordenados por rating
  Future<List<Venue>> findTopRated({int limit = 10});

  /// Sincroniza locais com o servidor
  Future<void> sync();

  /// Limpa o cache local
  Future<void> clearCache();
}
