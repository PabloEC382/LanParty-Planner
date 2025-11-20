import 'package:flutter/material.dart';
import '../infrastructure/repositories/events_repository_impl.dart';
import '../infrastructure/local/events_local_dao_shared_prefs.dart';
import '../infrastructure/mappers/event_mapper.dart';
import './dialogs/index.dart';
import './generic_list_page.dart';

/// Exemplo de como usar GenericListPage para Events
/// 
/// Este é um exemplo prático mostrando como reutilizar GenericListPage<T>
/// para qualquer entidade. Aqui estamos usando com Events.
/// 
/// Para outras entidades, basta trocar:
/// - Repository: eventsRepository → gamesRepository, etc.
/// - DTO: EventDto → GameDto, etc.
/// - Dialog: showEventFormDialog → showGameFormDialog, etc.

class EventsListPageGeneric extends StatefulWidget {
  const EventsListPageGeneric({super.key});

  @override
  State<EventsListPageGeneric> createState() => _EventsListPageGenericState();
}

class _EventsListPageGenericState extends State<EventsListPageGeneric> {
  late final eventsRepository = EventsRepositoryImpl(
    localDao: EventsLocalDaoSharedPrefs(),
  );

  @override
  Widget build(BuildContext context) {
    return GenericListPage<Map<String, dynamic>>(
      title: 'Eventos',
      loadData: _loadEvents,
      itemBuilder: (item) => ListTile(
        title: Text(item['name'] ?? 'Sem nome'),
        subtitle: Text('${item['start_date'] ?? ''} às ${item['start_time'] ?? ''}'),
        leading: const Icon(Icons.event),
      ),
      getItemId: (item) => item['id'] ?? '',
      getItemTitle: (item) => item['name'] ?? 'Evento',
      getItemSubtitle: (item) => '${item['start_date'] ?? ''} às ${item['start_time'] ?? ''}',
      onDelete: _deleteEvent,
      onAdd: _showAddEventDialog,
      onUpdate: _updateEvent,
    );
  }

  Future<List<Map<String, dynamic>>> _loadEvents() async {
    try {
      final events = await eventsRepository.listAll();
      return events
          .map((event) => {
                'id': event.id,
                'name': event.name,
                'start_date': event.startDate.toIso8601String().split('T')[0],
                'start_time': event.startTime,
              })
          .toList();
    } catch (e) {
      print('Erro ao carregar eventos: $e');
      rethrow;
    }
  }

  Future<void> _deleteEvent(String id) async {
    try {
      await eventsRepository.delete(id);
    } catch (e) {
      print('Erro ao deletar evento: $e');
      rethrow;
    }
  }

  Future<void> _updateEvent(Map<String, dynamic> item) async {
    // Implementar depois
    print('Editar evento: ${item['id']}');
  }

  Future<void> _showAddEventDialog() async {
    final dto = await showEventFormDialog(context);
    if (dto == null) return;

    try {
      final event = EventMapper.toEntity(dto);
      await eventsRepository.create(event);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Evento adicionado com sucesso!')),
      );

      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao adicionar evento: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
