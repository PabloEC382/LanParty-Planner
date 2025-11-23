import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../domain/entities/event.dart';
import '../../infrastructure/repositories/events_repository_impl.dart';
import '../../infrastructure/local/events_local_dao_shared_prefs.dart';

enum EventPeriodFilter {
  nextDays('Próximos 7 dias'),
  nextWeek('Próxima semana'),
  nextMonth('Próximo mês'),
  nextSixMonths('Próximos 6 meses'),
  nextYear('Próximo ano'),
  pastEvents('Eventos passados');

  final String label;
  const EventPeriodFilter(this.label);
}

class UpcomingEventsScreen extends StatefulWidget {
  const UpcomingEventsScreen({super.key});

  @override
  State<UpcomingEventsScreen> createState() => _UpcomingEventsScreenState();
}

class _UpcomingEventsScreenState extends State<UpcomingEventsScreen> {
  List<Event> _allEvents = [];
  List<Event> _filteredEvents = [];
  bool _loading = true;
  String? _error;
  late EventsRepositoryImpl _repository;

  EventPeriodFilter _selectedPeriod = EventPeriodFilter.nextDays;
  String? _selectedState;
  Set<String> _availableStates = {};

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
        _allEvents = events;
        _availableStates = events
            .map((e) => e.state ?? 'Desconhecido')
            .toSet();
        _filteredEvents = _filterEvents(events);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  List<Event> _filterEvents(List<Event> events) {
    List<Event> filtered = events;
    final now = DateTime.now();

    // Filtrar por período
    filtered = filtered.where((event) {
      switch (_selectedPeriod) {
        case EventPeriodFilter.nextDays:
          return event.startDate.isAfter(now) &&
              event.startDate.isBefore(now.add(const Duration(days: 7)));
        case EventPeriodFilter.nextWeek:
          final weekStart = now.add(Duration(days: 7 - now.weekday));
          final weekEnd = weekStart.add(const Duration(days: 7));
          return event.startDate.isAfter(weekStart) &&
              event.startDate.isBefore(weekEnd);
        case EventPeriodFilter.nextMonth:
          return event.startDate.isAfter(now) &&
              event.startDate.month == now.month &&
              event.startDate.year == now.year;
        case EventPeriodFilter.nextSixMonths:
          return event.startDate.isAfter(now) &&
              event.startDate.isBefore(now.add(const Duration(days: 180)));
        case EventPeriodFilter.nextYear:
          return event.startDate.isAfter(now) &&
              event.startDate.isBefore(now.add(const Duration(days: 365)));
        case EventPeriodFilter.pastEvents:
          return event.startDate.isBefore(now);
      }
    }).toList();

    // Filtrar por estado
    if (_selectedState != null) {
      filtered = filtered
          .where((event) => event.state == _selectedState)
          .toList();
    }

    // Ordenar por data
    filtered.sort((a, b) {
      return a.startDate.compareTo(b.startDate);
    });

    return filtered;
  }

  void _applyFilters() {
    setState(() {
      _filteredEvents = _filterEvents(_allEvents);
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Data não definida';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: slate,
      appBar: AppBar(
        backgroundColor: purple,
        title: const Text('Próximos Eventos'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filtros
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Período',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: EventPeriodFilter.values.map((period) {
                      final isSelected = _selectedPeriod == period;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(period.label),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() {
                              _selectedPeriod = period;
                              _applyFilters();
                            });
                          },
                          backgroundColor: slate.withValues(alpha: 0.5),
                          selectedColor: cyan,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Estado',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButton<String?>(
                  value: _selectedState,
                  dropdownColor: slate,
                  isExpanded: true,
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text(
                        'Todos os estados',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    ..._availableStates.map((state) {
                      return DropdownMenuItem(
                        value: state,
                        child: Text(
                          state,
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedState = value;
                      _applyFilters();
                    });
                  },
                  style: const TextStyle(color: Colors.white),
                  underline: Container(
                    height: 2,
                    color: cyan,
                  ),
                  icon: const Icon(Icons.arrow_drop_down, color: cyan),
                ),
              ],
            ),
          ),
          // Lista de eventos
          Expanded(
            child: _buildEventsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: cyan),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 16),
            Text(
              'Erro: $_error',
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_filteredEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _selectedPeriod == EventPeriodFilter.pastEvents
                  ? Icons.history
                  : Icons.event_busy,
              size: 64,
              color: Colors.white38,
            ),
            const SizedBox(height: 16),
            const Text(
              'Nenhum evento encontrado',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadEvents,
      color: cyan,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filteredEvents.length,
        itemBuilder: (context, index) {
          final event = _filteredEvents[index];
          final isPast =
              event.startDate.isBefore(DateTime.now());

          return Card(
            color: slate.withValues(alpha: 0.7),
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isPast)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Passado',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (event.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        event.description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 16, color: cyan),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(event.startDate),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.access_time, size: 16, color: cyan),
                      const SizedBox(width: 8),
                      Text(
                        event.startTime,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: cyan),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          event.state ?? 'Estado desconhecido',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
