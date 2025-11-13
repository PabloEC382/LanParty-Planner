import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../providers/domain/entities/event.dart';
import '../providers/infrastructure/dtos/event_dto.dart';
import '../providers/infrastructure/repositories/events_repository_impl.dart';
import '../providers/infrastructure/local/events_local_dao_shared_prefs.dart';
import '../providers/presentation/dialogs/event_form_dialog.dart';

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

  Future<void> _showAddEventDialog() async {
    final result = await showEventFormDialog(context);
    if (result != null) {
      try {
        await _repository.create(
          Event(
            id: result.id,
            name: result.name,
            eventDate: DateTime.parse(result.event_date),
            checklist: result.checklist.cast<String, bool>(),
            attendees: result.attendees,
            updatedAt: DateTime.parse(result.updated_at),
          ),
        );
        
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
        await _repository.update(
          Event(
            id: result.id,
            name: result.name,
            eventDate: DateTime.parse(result.event_date),
            checklist: result.checklist.cast<String, bool>(),
            attendees: result.attendees,
            updatedAt: DateTime.parse(result.updated_at),
          ),
        );
        
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

  Future<void> _deleteEvent(String eventId, int index) async {
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

  EventDto _convertEventToDto(Event event) {
    return EventDto(
      id: event.id,
      name: event.name,
      event_date: event.eventDate.toIso8601String().split('T')[0],
      checklist: event.checklist.cast<String, dynamic>(),
      attendees: event.attendees,
      updated_at: event.updatedAt.toIso8601String(),
    );
  }

  Widget _buildBody() {
    if (_loading)
      return const Center(child: CircularProgressIndicator(color: cyan));
    if (_error != null)
      return Center(
        child: Text(
          'Erro: $_error',
          style: const TextStyle(color: Colors.white),
        ),
      );
    if (_events.isEmpty)
      return const Center(
        child: Text('Nenhum evento', style: TextStyle(color: Colors.white70)),
      );

    return RefreshIndicator(
      onRefresh: _loadEvents,
      color: purple,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];
          final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
          
          return Dismissible(
            key: Key(event.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 16),
              color: Colors.red,
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (_) => _deleteEvent(event.id, index),
            child: Card(
              color: slate.withOpacity(0.5),
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Icon(
                  event.isComplete ? Icons.check_circle : Icons.event,
                  color: event.isComplete ? cyan : Colors.white38,
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
                      dateFormat.format(event.eventDate),
                      style: TextStyle(color: cyan, fontSize: 12),
                    ),
                    Text(
                      '${event.attendeeCount} participantes',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Text(
                      event.summary,
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
          );
        },
      ),
    );
  }
}
