import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../events/domain/entities/event.dart';
import '../../../events/presentation/pages/event_detail_screen.dart';
import '../../../events/infrastructure/repositories/events_repository_impl.dart';
import '../../../events/infrastructure/local/events_local_dao_shared_prefs.dart';
import '../../../events/infrastructure/remote/supabase_events_remote_datasource.dart';

class UpcomingEventsWidget extends StatefulWidget {
  const UpcomingEventsWidget({super.key}) : super();

  @override
  State<UpcomingEventsWidget> createState() => _UpcomingEventsWidgetState();
}

class _UpcomingEventsWidgetState extends State<UpcomingEventsWidget> {
  late EventsRepositoryImpl _repository;
  List<Event> _upcomingEvents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _repository = EventsRepositoryImpl(
      remoteApi: SupabaseEventsRemoteDatasource(),
      localDao: EventsLocalDaoSharedPrefs(),
    );
    _loadUpcomingEvents();
  }

  Future<void> _loadUpcomingEvents() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // 1. Carregar dados do cache local primeiro
      if (kDebugMode) {
        print('UpcomingEventsWidget._loadUpcomingEvents: carregando dados do cache...');
      }
      final cachedEvents = await _repository.loadFromCache();
      
      // 2. Se o cache estiver vazio, sincronizar com o servidor
      if (cachedEvents.isEmpty) {
        if (kDebugMode) {
          print('UpcomingEventsWidget._loadUpcomingEvents: cache vazio, sincronizando...');
        }
        try {
          final syncedCount = await _repository.syncFromServer();
          if (kDebugMode) {
            print('UpcomingEventsWidget._loadUpcomingEvents: sync concluído, $syncedCount registros');
          }
        } catch (syncError) {
          if (kDebugMode) {
            print('UpcomingEventsWidget._loadUpcomingEvents: erro ao sincronizar - $syncError');
          }
        }
      }
      
      // 3. Recarregar dados do cache e filtrar próxima semana
      final allEvents = await _repository.listAll();
      
      final now = DateTime.now();
      final nextWeek = now.add(const Duration(days: 7));
      
      final upcoming = allEvents
          .where((event) {
            return event.startDate.isAfter(now) && 
                   event.startDate.isBefore(nextWeek);
          })
          .toList()
          ..sort((a, b) => a.startDate.compareTo(b.startDate));

      if (mounted) {
        setState(() {
          _upcomingEvents = upcoming;
          _isLoading = false;
        });
        if (kDebugMode) {
          print('UpcomingEventsWidget._loadUpcomingEvents: UI atualizada com ${upcoming.length} eventos para próxima semana');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        if (kDebugMode) {
          print('UpcomingEventsWidget._loadUpcomingEvents: erro ao carregar - $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.purple),
                SizedBox(width: 8),
                Text(
                  'Próximos Eventos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Content
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(color: Colors.purple),
              ),
            )
          else if (_upcomingEvents.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.event_busy,
                      size: 48,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Nenhum evento próximo',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: _upcomingEvents.take(3).map((event) {
                return _buildEventTile(context, event);
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildEventTile(BuildContext context, Event event) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => EventDetailScreen(
              event: event,
              onEventUpdated: () {},
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey[800]!),
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${event.startDate.day}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                  Text(
                    _monthName(event.startDate.month),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.startTime,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];
    return months[month - 1];
  }
}
