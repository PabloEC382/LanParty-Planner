import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../providers/domain/entities/venue.dart';
import '../providers/infrastructure/dtos/venue_dto.dart';
import '../providers/infrastructure/repositories/venues_repository_impl.dart';
import '../providers/infrastructure/local/venues_local_dao_shared_prefs.dart';
import '../providers/presentation/dialogs/venue_form_dialog.dart';

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

  VenueDto _convertVenueToDto(Venue venue) {
    return VenueDto(
      id: venue.id,
      name: venue.name,
      address: venue.address,
      city: venue.city,
      state: venue.state,
      zip_code: venue.zipCode,
      latitude: venue.latitude,
      longitude: venue.longitude,
      capacity: venue.capacity,
      price_per_hour: venue.pricePerHour,
      facilities: venue.facilities.toList(),
      rating: venue.rating,
      total_reviews: venue.totalReviews,
      is_verified: venue.isVerified,
      website_url: venue.websiteUri?.toString(),
      phone_number: venue.phoneNumber,
      created_at: venue.createdAt.toIso8601String(),
      updated_at: venue.updatedAt.toIso8601String(),
    );
  }

  Future<void> _showAddVenueDialog() async {
    final result = await showVenueFormDialog(context);
    if (result != null) {
      try {
        final newVenue = Venue(
          id: result.id,
          name: result.name,
          address: result.address,
          city: result.city,
          state: result.state,
          zipCode: result.zip_code,
          latitude: result.latitude,
          longitude: result.longitude,
          capacity: result.capacity,
          pricePerHour: result.price_per_hour,
          facilities: (result.facilities ?? []).toSet(),
          rating: result.rating,
          totalReviews: result.total_reviews,
          isVerified: result.is_verified,
          websiteUri: result.website_url != null ? Uri.tryParse(result.website_url!) : null,
          phoneNumber: result.phone_number,
          createdAt: DateTime.parse(result.created_at),
          updatedAt: DateTime.parse(result.updated_at),
        );
        
        await _repository.create(newVenue);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Local adicionado com sucesso!')),
          );
          _loadVenues();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao adicionar local: $e')),
          );
        }
      }
    }
  }

  Future<void> _showEditVenueDialog(Venue venue) async {
    final venueDto = _convertVenueToDto(venue);
    final result = await showVenueFormDialog(context, initial: venueDto);
    if (result != null) {
      try {
        final updatedVenue = Venue(
          id: result.id,
          name: result.name,
          address: result.address,
          city: result.city,
          state: result.state,
          zipCode: result.zip_code,
          latitude: result.latitude,
          longitude: result.longitude,
          capacity: result.capacity,
          pricePerHour: result.price_per_hour,
          facilities: (result.facilities ?? []).toSet(),
          rating: result.rating,
          totalReviews: result.total_reviews,
          isVerified: result.is_verified,
          websiteUri: result.website_url != null ? Uri.tryParse(result.website_url!) : null,
          phoneNumber: result.phone_number,
          createdAt: DateTime.parse(result.created_at),
          updatedAt: DateTime.parse(result.updated_at),
        );
        
        await _repository.update(updatedVenue);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Local atualizado com sucesso!')),
          );
          _loadVenues();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao atualizar local: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteVenue(String venueId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Tem certeza que deseja deletar este local?'),
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
        await _repository.delete(venueId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Local deletado com sucesso!')),
          );
          _loadVenues();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao deletar local: $e')),
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
        title: const Text('Locais'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadVenues),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddVenueDialog,
        backgroundColor: purple,
        child: const Icon(Icons.add),
      ),
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
    if (_venues.isEmpty)
      return const Center(
        child: Text('Nenhum local', style: TextStyle(color: Colors.white70)),
      );

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
            onDismissed: (_) => _deleteVenue(venue.id),
            child: Card(
              color: slate.withOpacity(0.5),
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Icon(
                  Icons.place,
                  color: venue.isVerified ? cyan : Colors.white38,
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
                      style: TextStyle(color: cyan, fontSize: 12),
                    ),
                    Text(
                      venue.capacityCategory,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Text(
                      venue.priceDisplay,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Text(
                      venue.badge,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white38),
                  onPressed: () => _showEditVenueDialog(venue),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
