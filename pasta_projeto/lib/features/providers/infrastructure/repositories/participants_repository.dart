import '../../domain/entities/participant.dart';
import '../datasources/participants_remote_datasource.dart';
import '../mappers/participant_mapper.dart';

class ParticipantsRepository {
  final ParticipantsRemoteDataSource _remoteDataSource;

  ParticipantsRepository({ParticipantsRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? ParticipantsRemoteDataSource();

  Future<List<Participant>> getAllParticipants() async {
    try {
      final dtos = await _remoteDataSource.fetchAllParticipants();
      return ParticipantMapper.toEntities(dtos);
    } catch (e) {
      print('❌ ParticipantsRepository.getAllParticipants: $e');
      rethrow;
    }
  }

  Future<Participant?> getParticipantById(String id) async {
    try {
      final dto = await _remoteDataSource.fetchParticipantById(id);
      if (dto == null) return null;
      return ParticipantMapper.toEntity(dto);
    } catch (e) {
      print('❌ ParticipantsRepository.getParticipantById: $e');
      rethrow;
    }
  }

  Future<Participant> createParticipant(Participant participant) async {
    try {
      final dto = ParticipantMapper.toDto(participant);
      final createdDto = await _remoteDataSource.createParticipant(dto);
      return ParticipantMapper.toEntity(createdDto);
    } catch (e) {
      print('❌ ParticipantsRepository.createParticipant: $e');
      rethrow;
    }
  }

  Future<Participant> updateParticipant(Participant participant) async {
    try {
      final dto = ParticipantMapper.toDto(participant);
      final updatedDto = await _remoteDataSource.updateParticipant(participant.id, dto);
      return ParticipantMapper.toEntity(updatedDto);
    } catch (e) {
      print('❌ ParticipantsRepository.updateParticipant: $e');
      rethrow;
    }
  }

  Future<void> deleteParticipant(String id) async {
    try {
      await _remoteDataSource.deleteParticipant(id);
    } catch (e) {
      print('❌ ParticipantsRepository.deleteParticipant: $e');
      rethrow;
    }
  }

  Future<List<Participant>> getPremiumParticipants() async {
    try {
      final dtos = await _remoteDataSource.fetchPremiumParticipants();
      return ParticipantMapper.toEntities(dtos);
    } catch (e) {
      print('❌ ParticipantsRepository.getPremiumParticipants: $e');
      rethrow;
    }
  }
}