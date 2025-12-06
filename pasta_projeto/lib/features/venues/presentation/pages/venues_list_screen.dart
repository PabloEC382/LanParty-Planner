import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../core/theme.dart';
import '../../../home/presentation/widgets/app_bar_helper.dart';
import '../../../home/presentation/widgets/complete_drawer_helper.dart';
import '../../../../services/shared_preferences_services.dart';
import '../../domain/entities/venue.dart';
import '../../infrastructure/repositories/venues_repository_impl.dart';
import '../../infrastructure/local/venues_local_dao_shared_prefs.dart';
import '../../infrastructure/remote/supabase_venues_remote_datasource.dart';
import 'venue_detail_screen.dart';

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
  String? _userName;
  String? _userEmail;
  String? _userPhotoPath;

  @override
  void initState() {
    super.initState();
    _repository = VenuesRepositoryImpl(
      remoteApi: SupabaseVenuesRemoteDatasource(),
      localDao: VenuesLocalDaoSharedPrefs(),
    );
    _loadUserData();
    _loadVenues();
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

  Future<void> _loadVenues() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // 1. Carregar dados do cache local primeiro
      if (kDebugMode) {
        print('VenuesListScreen._loadVenues: carregando dados do cache local...');
      }
      final cachedVenues = await _repository.loadFromCache();
      
      // 2. Se o cache estiver vazio, sincronizar com o servidor
      if (cachedVenues.isEmpty) {
        if (kDebugMode) {
          print('VenuesListScreen._loadVenues: cache vazio, sincronizando com servidor...');
        }
        try {
          final syncedCount = await _repository.syncFromServer();
          if (kDebugMode) {
            print('VenuesListScreen._loadVenues: sincronização concluída, $syncedCount registros aplicados');
          }
        } catch (syncError) {
          if (kDebugMode) {
            print('VenuesListScreen._loadVenues: erro ao sincronizar - $syncError');
          }
        }
      }
      
      // 3. Recarregar dados do cache
      final venues = await _repository.listAll();
      if (mounted) {
        setState(() {
          _venues = venues;
          _loading = false;
        });
        if (kDebugMode) {
          print('VenuesListScreen._loadVenues: UI atualizada com ${venues.length} locais');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
        if (kDebugMode) {
          print('VenuesListScreen._loadVenues: erro ao carregar - $e');
        }
      }
    }
  }

  Future<void> _showAddVenueDialog() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Criação de locais é gerenciada pelo servidor.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _showEditVenueDialog(Venue venue) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edição de locais é gerenciada pelo servidor.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _deleteVenue(String venueId) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Deleção de locais é gerenciada pelo servidor.'),
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
        title: 'Locais',
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadVenues),
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
              onLongPress: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Gerenciamento de locais é feito pelo servidor'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
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
                color: slate.withValues(alpha: 0.5),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                leading: const Icon(
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
