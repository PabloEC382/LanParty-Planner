import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../providers/domain/entities/venue.dart';
import '../providers/infrastructure/repositories/venues_repository.dart';

class VenuesListScreen extends StatefulWidget {
  const VenuesListScreen({super.key});

  @override
  State<VenuesListScreen> createState() => _VenuesListScreenState();
}

class _VenuesListScreenState extends State<VenuesListScreen> {
  final _repository = VenuesRepository();
  List<Venue> _venues = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadVenues();
  }

  Future<void> _loadVenues() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final venues = await _repository.getAllVenues();
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
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator(color: cyan));
    if (_error != null) return Center(child: Text('Erro: $_error', style: const TextStyle(color: Colors.white)));
    if (_venues.isEmpty) return const Center(child: Text('Nenhum local', style: TextStyle(color: Colors.white70)));

    return RefreshIndicator(
      onRefresh: _loadVenues,
      color: purple,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _venues.length,
        itemBuilder: (context, index) {
          final venue = _venues[index];
          return Card(
            color: slate.withOpacity(0.5),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(Icons.place, color: venue.isVerified ? cyan : Colors.white38, size: 40),
              title: Text(venue.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text('${venue.city} - ${venue.state}', style: TextStyle(color: cyan, fontSize: 12)),
                  Text(venue.capacityCategory, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  Text(venue.priceDisplay, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  Text(venue.badge, style: const TextStyle(color: Colors.white70, fontSize: 12)),
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