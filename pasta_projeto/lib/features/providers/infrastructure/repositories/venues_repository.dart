import '../../domain/entities/venue.dart';
import '../datasources/venues_remote_datasource.dart';
import '../mappers/venue_mapper.dart';

class VenuesRepository {
  final VenuesRemoteDataSource _remoteDataSource;

  VenuesRepository({VenuesRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? VenuesRemoteDataSource();

  Future<List<Venue>> getAllVenues() async {
    try {
      final dtos = await _remoteDataSource.fetchAllVenues();
      return VenueMapper.toEntities(dtos);
    } catch (e) {
      print('❌ VenuesRepository.getAllVenues: $e');
      rethrow;
    }
  }

  Future<Venue?> getVenueById(String id) async {
    try {
      final dto = await _remoteDataSource.fetchVenueById(id);
      if (dto == null) return null;
      return VenueMapper.toEntity(dto);
    } catch (e) {
      print('❌ VenuesRepository.getVenueById: $e');
      rethrow;
    }
  }

  Future<Venue> createVenue(Venue venue) async {
    try {
      final dto = VenueMapper.toDto(venue);
      final createdDto = await _remoteDataSource.createVenue(dto);
      return VenueMapper.toEntity(createdDto);
    } catch (e) {
      print('❌ VenuesRepository.createVenue: $e');
      rethrow;
    }
  }

  Future<Venue> updateVenue(Venue venue) async {
    try {
      final dto = VenueMapper.toDto(venue);
      final updatedDto = await _remoteDataSource.updateVenue(venue.id, dto);
      return VenueMapper.toEntity(updatedDto);
    } catch (e) {
      print('❌ VenuesRepository.updateVenue: $e');
      rethrow;
    }
  }

  Future<void> deleteVenue(String id) async {
    try {
      await _remoteDataSource.deleteVenue(id);
    } catch (e) {
      print('❌ VenuesRepository.deleteVenue: $e');
      rethrow;
    }
  }

  Future<List<Venue>> getVerifiedVenues() async {
    try {
      final dtos = await _remoteDataSource.fetchVerifiedVenues();
      return VenueMapper.toEntities(dtos);
    } catch (e) {
      print('❌ VenuesRepository.getVerifiedVenues: $e');
      rethrow;
    }
  }

  Future<List<Venue>> getVenuesByCity(String city) async {
    try {
      final dtos = await _remoteDataSource.fetchVenuesByCity(city);
      return VenueMapper.toEntities(dtos);
    } catch (e) {
      print('❌ VenuesRepository.getVenuesByCity: $e');
      rethrow;
    }
  }
}