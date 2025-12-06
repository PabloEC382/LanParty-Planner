import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import '../../../core/theme.dart';
import '../../../home/presentation/widgets/app_bar_helper.dart';
import '../../../home/presentation/widgets/complete_drawer_helper.dart';
import '../../../../services/shared_preferences_services.dart';
import '../../domain/entities/event.dart';
import '../../infrastructure/repositories/events_repository_impl.dart';
import '../../infrastructure/local/events_local_dao_shared_prefs.dart';
import '../../infrastructure/remote/supabase_events_remote_datasource.dart';
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
  String? _userName;
  String? _userEmail;
  String? _userPhotoPath;

  @override
  void initState() {
    super.initState();
    _repository = EventsRepositoryImpl(
      remoteApi: SupabaseEventsRemoteDatasource(),
      localDao: EventsLocalDaoSharedPrefs(),
    );
    _loadEvents();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final name = await SharedPreferencesService.getUserName();
    final email = await SharedPreferencesService.getUserEmail();
    final photo = await SharedPreferencesService.getUserPhotoPath();
    if (mounted) {
      setState(() {
        _userName = name;
        _userEmail = email;
        _userPhotoPath = photo;
      });
    }
  }
  Future<void> _loadEvents() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // 1. Carregar dados do cache local primeiro
      if (kDebugMode) {
        print('EventsListScreen._loadEvents: carregando dados do cache local...');
      }
      final cachedEvents = await _repository.loadFromCache();
      
      // 2. Se o cache estiver vazio, sincronizar com o servidor
      if (cachedEvents.isEmpty) {
        if (kDebugMode) {
          print('EventsListScreen._loadEvents: cache vazio, sincronizando com servidor...');
        }
        try {
          final syncedCount = await _repository.syncFromServer();
          if (kDebugMode) {
            print('EventsListScreen._loadEvents: sincronização concluída, $syncedCount registros aplicados');
          }
        } catch (syncError) {
          if (kDebugMode) {
            print('EventsListScreen._loadEvents: erro ao sincronizar - $syncError');
          }
        }
      }
      
      // 3. Recarregar dados do cache
      final events = await _repository.listAll();
      if (mounted) {
        setState(() {
          _events = events;
          _loading = false;
        });
        if (kDebugMode) {
          print('EventsListScreen._loadEvents: UI atualizada com ${events.length} eventos');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
        if (kDebugMode) {
          print('EventsListScreen._loadEvents: erro ao carregar - $e');
        }
      }
    }
  }


  Future<void> _showAddEventDialog() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Criação de eventos é gerenciada pelo servidor.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _showEditEventDialog(Event event) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edição de eventos é gerenciada pelo servidor.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _deleteEvent(String eventId) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Deleção de eventos é gerenciada pelo servidor.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: slate,
      appBar: buildAppBarWithHome(
        context,
        title: 'Eventos',
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadEvents),
        ],
      ),
      drawer: buildCompleteDrawer(
        context,
        userName: _userName,
        userEmail: _userEmail,
        userPhotoPath: _userPhotoPath,
        onUserDataUpdated: _loadUserData,
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
              onLongPress: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Gerenciamento de eventos é feito pelo servidor'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
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
                color: slate.withValues(alpha: 0.5),
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
