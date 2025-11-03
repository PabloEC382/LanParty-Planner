import '../../domain/entities/tournament.dart';
import '../datasources/tournaments_remote_datasource.dart';
import '../mappers/tournament_mapper.dart';

class TournamentsRepository {
  final TournamentsRemoteDataSource _remoteDataSource;

  TournamentsRepository({TournamentsRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? TournamentsRemoteDataSource();

  Future<List<Tournament>> getAllTournaments() async {
    try {
      final dtos = await _remoteDataSource.fetchAllTournaments();
      return TournamentMapper.toEntities(dtos);
    } catch (e) {
      print('❌ TournamentsRepository.getAllTournaments: $e');
      rethrow;
    }
  }

  Future<Tournament?> getTournamentById(String id) async {
    try {
      final dto = await _remoteDataSource.fetchTournamentById(id);
      if (dto == null) return null;
      return TournamentMapper.toEntity(dto);
    } catch (e) {
      print('❌ TournamentsRepository.getTournamentById: $e');
      rethrow;
    }
  }

  Future<Tournament> createTournament(Tournament tournament) async {
    try {
      final dto = TournamentMapper.toDto(tournament);
      final createdDto = await _remoteDataSource.createTournament(dto);
      return TournamentMapper.toEntity(createdDto);
    } catch (e) {
      print('❌ TournamentsRepository.createTournament: $e');
      rethrow;
    }
  }

  Future<Tournament> updateTournament(Tournament tournament) async {
    try {
      final dto = TournamentMapper.toDto(tournament);
      final updatedDto = await _remoteDataSource.updateTournament(tournament.id, dto);
      return TournamentMapper.toEntity(updatedDto);
    } catch (e) {
      print('❌ TournamentsRepository.updateTournament: $e');
      rethrow;
    }
  }

  Future<void> deleteTournament(String id) async {
    try {
      await _remoteDataSource.deleteTournament(id);
    } catch (e) {
      print('❌ TournamentsRepository.deleteTournament: $e');
      rethrow;
    }
  }

  Future<List<Tournament>> getActiveRegistrations() async {
    try {
      final dtos = await _remoteDataSource.fetchActiveRegistrations();
      return TournamentMapper.toEntities(dtos);
    } catch (e) {
      print('❌ TournamentsRepository.getActiveRegistrations: $e');
      rethrow;
    }
  }

  Future<List<Tournament>> getTournamentsByGame(String gameId) async {
    try {
      final dtos = await _remoteDataSource.fetchTournamentsByGame(gameId);
      return TournamentMapper.toEntities(dtos);
    } catch (e) {
      print('❌ TournamentsRepository.getTournamentsByGame: $e');
      rethrow;
    }
  }
}