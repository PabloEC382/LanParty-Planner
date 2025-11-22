import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme.dart';
import '../../domain/entities/event.dart';
import '../../infrastructure/dtos/event_dto.dart';
import '../../infrastructure/repositories/events_repository_impl.dart';
import '../../infrastructure/local/events_local_dao_shared_prefs.dart';
import '../dialogs/event_form_dialog.dart';
import '../dialogs/event_actions_dialog.dart';
import 'event_detail_screen.dart';

class EventsListScreen extends StatefulWidget {
  const EventsListScreen({super.key});

  @override
  State<EventsListScreen> createState() => _EventsListScreenState();
}

class _EventsListScreenState extends State<EventsListScreen> {
  List<Event> _events = [];
  bool _loading = true;
  String? _error;
  late EventsRepositoryImpl _repository;

  @override
  void initState() {
    super.initState();
    _repository = EventsRepositoryImpl(localDao: EventsLocalDaoSharedPrefs());
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final events = await _repository.listAll();
      setState(() {
        _events = events;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  EventDto _convertEventToDto(Event event) {
    return EventDto(
      id: event.id,
      name: event.name,
      start_date: event.startDate.toIso8601String(),
      end_date: event.endDate.toIso8601String(),
      description: event.description,
      start_time: event.startTime,
      end_time: event.endTime,
      venue_id: event.venueId,
      created_at: event.createdAt.toIso8601String(),
      updated_at: event.updatedAt.toIso8601String(),
    );
  }

  Future<void> _showAddEventDialog() async {
    final result = await showEventFormDialog(context);
    if (result != null) {
      try {
        final newEvent = Event(
          id: result.id,
          name: result.name,
          startDate: DateTime.parse(result.start_date),
          endDate: DateTime.parse(result.end_date),
          description: result.description,
          startTime: result.start_time,
          endTime: result.end_time,
          venueId: result.venue_id,
          createdAt: DateTime.parse(result.created_at),
          updatedAt: DateTime.parse(result.updated_at),
        );
        
        await _repository.create(newEvent);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Evento adicionado com sucesso!')),
          );
          _loadEvents();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao adicionar evento: $e')),
          );
        }
      }
    }
  }

  Future<void> _showEditEventDialog(Event event) async {
    final eventDto = _convertEventToDto(event);
    final result = await showEventFormDialog(context, initial: eventDto);
    if (result != null) {
      try {
        final updatedEvent = Event(
          id: result.id,
          name: result.name,
          startDate: DateTime.parse(result.start_date),
          endDate: DateTime.parse(result.end_date),
          description: result.description,
          startTime: result.start_time,
          endTime: result.end_time,
          venueId: result.venue_id,
          createdAt: DateTime.parse(result.created_at),
          updatedAt: DateTime.parse(result.updated_at),
        );
        
        await _repository.update(updatedEvent);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Evento atualizado com sucesso!')),
          );
          _loadEvents();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao atualizar evento: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteEvent(String eventId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Tem certeza que deseja deletar este evento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Deletar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _repository.delete(eventId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Evento deletado com sucesso!')),
          );
          _loadEvents();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao deletar evento: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: slate,
      appBar: AppBar(
        backgroundColor: purple,
        title: const Text('Eventos'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadEvents),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEventDialog,
        backgroundColor: purple,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: cyan));
    }
    if (_error != null) {
      return Center(
        child: Text(
          'Erro: $_error',
          style: const TextStyle(color: Colors.white),
        ),
      );
    }
    if (_events.isEmpty) {
      return const Center(
        child: Text('Nenhum evento', style: TextStyle(color: Colors.white70)),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadEvents,
      color: purple,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];
          final dateFormat = DateFormat('dd/MM/yyyy');
          
          return Dismissible(
            key: Key(event.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 16),
              color: Colors.red,
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            confirmDismiss: (direction) async {
              return await showDialog<bool>(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  backgroundColor: slate,
                  title: const Text(
                    'Confirmar exclusão',
                    style: TextStyle(color: Colors.white),
                  ),
                  content: Text(
                    'Tem certeza que deseja remover "${event.name}"?',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Remover',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ) ?? false;
            },
            onDismissed: (_) => _deleteEvent(event.id),
            child: GestureDetector(
              onLongPress: () => showEventActionsDialog(
                context,
                event: event,
                onEdit: () => _showEditEventDialog(event),
                onDelete: () => _deleteEvent(event.id),
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventDetailScreen(
                    event: event,
                    onEventUpdated: _loadEvents,
                  ),
                ),
              ),
              child: Card(
                color: slate.withOpacity(0.5),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(
                    Icons.event,
                    color: cyan,
                    size: 40,
                  ),
                  title: Text(
                    event.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        'Início: ${dateFormat.format(event.startDate)} às ${event.startTime}',
                        style: const TextStyle(color: cyan, fontSize: 12),
                      ),
                      Text(
                        'Fim: ${dateFormat.format(event.endDate)} às ${event.endTime}',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        event.description,
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (event.venueId != null)
                        Text(
                          'Local: ${event.venueId}',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white38),
                    onPressed: () => _showEditEventDialog(event),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
