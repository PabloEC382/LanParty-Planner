import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../providers/domain/entities/event.dart';
import '../providers/infrastructure/repositories/events_repository.dart';

class EventsListScreen extends StatefulWidget {
  const EventsListScreen({super.key});

  @override
  State<EventsListScreen> createState() => _EventsListScreenState();
}

class _EventsListScreenState extends State<EventsListScreen> {
  final _repository = EventsRepository();
  List<Event> _events = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final events = await _repository.getAllEvents();
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
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator(color: cyan));
    if (_error != null) return Center(child: Text('Erro: $_error', style: const TextStyle(color: Colors.white)));
    if (_events.isEmpty) return const Center(child: Text('Nenhum evento', style: TextStyle(color: Colors.white70)));

    return RefreshIndicator(
      onRefresh: _loadEvents,
      color: purple,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];
          final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
          return Card(
            color: slate.withOpacity(0.5),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(
                event.isComplete ? Icons.check_circle : Icons.event,
                color: event.isComplete ? cyan : Colors.white38,
                size: 40,
              ),
              title: Text(event.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(dateFormat.format(event.eventDate), style: TextStyle(color: cyan, fontSize: 12)),
                  Text('${event.attendeeCount} participantes', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  Text(event.summary, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 16),
            ),
          );
        },
      ),
    );
  }
}