import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../providers/domain/entities/venue.dart';
import '../providers/infrastructure/repositories/venues_repository_impl.dart';
import '../providers/infrastructure/local/venues_local_dao_shared_prefs.dart';
import '../providers/presentation/dialogs/venue_form_dialog.dart';
import '../providers/presentation/dialogs/venue_actions_dialog.dart';
import '../providers/infrastructure/mappers/venue_mapper.dart';
import '../providers/presentation/screens/venue_detail_screen.dart';

class VenuesListScreen extends StatefulWidget {
  const VenuesListScreen({super.key});

  @override
  State<VenuesListScreen> createState() => _VenuesListScreenState();
}

class _VenuesListScreenState extends State<VenuesListScreen> {
  List<Venue> _venues = [];
  bool _loading = true;
  String? _error;
  late VenuesRepositoryImpl _repository;

  @override
  void initState() {
    super.initState();
    _repository = VenuesRepositoryImpl(localDao: VenuesLocalDaoSharedPrefs());
    _loadVenues();
  }

  Future<void> _loadVenues() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final venues = await _repository.listAll();
      setState(() {
        _venues = venues;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _showAddVenueDialog() async {
    final result = await showVenueFormDialog(context);
    if (result != null && mounted) {
      try {
        final venue = VenueMapper.toEntity(result);
        await _repository.create(venue);
        await _loadVenues();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Local adicionado com sucesso!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao adicionar: $e')),
          );
        }
      }
    }
  }

  Future<void> _showEditVenueDialog(Venue venue) async {
    final dto = VenueMapper.toDto(venue);
    final result = await showVenueFormDialog(context, initial: dto);
    if (result != null && mounted) {
      try {
        final updatedVenue = VenueMapper.toEntity(result);
        await _repository.update(updatedVenue);
        await _loadVenues();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Local atualizado com sucesso!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao atualizar: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteVenue(String venueId) async {
    try {
      await _repository.delete(venueId);
      await _loadVenues();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Local deletado com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao deletar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: slate,
      appBar: AppBar(
        backgroundColor: purple,
        title: const Text('Locais'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadVenues),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: cyan,
        onPressed: _showAddVenueDialog,
        child: const Icon(Icons.add, color: Colors.black),
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
    if (_venues.isEmpty) {
      return const Center(
        child: Text('Nenhum local', style: TextStyle(color: Colors.white70)),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadVenues,
      color: purple,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _venues.length,
        itemBuilder: (context, index) {
          final venue = _venues[index];
          return Dismissible(
            key: Key(venue.id),
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
                    'Tem certeza que deseja remover "${venue.name}"?',
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
            onDismissed: (_) => _deleteVenue(venue.id),
            child: GestureDetector(
              onLongPress: () => showVenueActionsDialog(
                context,
                venue: venue,
                onEdit: () => _showEditVenueDialog(venue),
                onDelete: () => _deleteVenue(venue.id),
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VenueDetailScreen(
                    venue: venue,
                    onVenueUpdated: _loadVenues,
                  ),
                ),
              ),
              child: Card(
                color: slate.withOpacity(0.5),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                leading: Icon(
                  Icons.place,
                  color: cyan,
                  size: 40,
                ),
                title: Text(
                  venue.name,
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
                      '${venue.city} - ${venue.state}',
                      style: const TextStyle(color: cyan, fontSize: 12),
                    ),
                    Text(
                      venue.capacityCategory,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Text(
                      venue.ratingDisplay,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit, color: cyan),
                  onPressed: () => _showEditVenueDialog(venue),
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
