import '../../domain/entities/event.dart';
import '../datasources/events_remote_datasource.dart';
import '../mappers/event_mapper.dart';

class EventsRepository {
  final EventsRemoteDataSource _remoteDataSource;

  EventsRepository({EventsRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? EventsRemoteDataSource();

  Future<List<Event>> getAllEvents() async {
    try {
      final dtos = await _remoteDataSource.fetchAllEvents();
      return EventMapper.toEntities(dtos);
    } catch (e) {
      print('❌ EventsRepository.getAllEvents: $e');
      rethrow;
    }
  }

  Future<Event?> getEventById(String id) async {
    try {
      final dto = await _remoteDataSource.fetchEventById(id);
      if (dto == null) return null;
      return EventMapper.toEntity(dto);
    } catch (e) {
      print('❌ EventsRepository.getEventById: $e');
      rethrow;
    }
  }

  Future<Event> createEvent(Event event) async {
    try {
      final dto = EventMapper.toDto(event);
      final createdDto = await _remoteDataSource.createEvent(dto);
      return EventMapper.toEntity(createdDto);
    } catch (e) {
      print('❌ EventsRepository.createEvent: $e');
      rethrow;
    }
  }

  Future<Event> updateEvent(Event event) async {
    try {
      final dto = EventMapper.toDto(event);
      final updatedDto = await _remoteDataSource.updateEvent(event.id, dto);
      return EventMapper.toEntity(updatedDto);
    } catch (e) {
      print('❌ EventsRepository.updateEvent: $e');
      rethrow;
    }
  }

  Future<void> deleteEvent(String id) async {
    try {
      await _remoteDataSource.deleteEvent(id);
    } catch (e) {
      print('❌ EventsRepository.deleteEvent: $e');
      rethrow;
    }
  }

  Future<List<Event>> getUpcomingEvents() async {
    try {
      final dtos = await _remoteDataSource.fetchUpcomingEvents();
      return EventMapper.toEntities(dtos);
    } catch (e) {
      print('❌ EventsRepository.getUpcomingEvents: $e');
      rethrow;
    }
  }

  Future<List<Event>> syncEvents(DateTime lastSyncTime) async {
    try {
      final dtos = await _remoteDataSource.fetchUpdatedEvents(lastSyncTime);
      return EventMapper.toEntities(dtos);
    } catch (e) {
      print('❌ EventsRepository.syncEvents: $e');
      rethrow;
    }
  }
}