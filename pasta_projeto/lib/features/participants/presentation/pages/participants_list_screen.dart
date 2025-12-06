import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../core/theme.dart';
import '../../../home/presentation/widgets/app_bar_helper.dart';
import '../../../home/presentation/widgets/complete_drawer_helper.dart';
import '../../../../services/shared_preferences_services.dart';
import '../../domain/entities/participant.dart';
import '../../infrastructure/repositories/participants_repository_impl.dart';
import '../../infrastructure/local/participants_local_dao_shared_prefs.dart';
import '../../infrastructure/remote/supabase_participants_remote_datasource.dart';
import 'participant_detail_screen.dart';

class ParticipantsListScreen extends StatefulWidget {
  const ParticipantsListScreen({super.key});

  @override
  State<ParticipantsListScreen> createState() => _ParticipantsListScreenState();
}

class _ParticipantsListScreenState extends State<ParticipantsListScreen> {
  List<Participant> _participants = [];
  bool _loading = true;
  String? _error;
  late ParticipantsRepositoryImpl _repository;
  String? _userName;
  String? _userEmail;
  String? _userPhotoPath;

  @override
  void initState() {
    super.initState();
    _repository = ParticipantsRepositoryImpl(
      remoteApi: SupabaseParticipantsRemoteDatasource(),
      localDao: ParticipantsLocalDaoSharedPrefs(),
    );
    _loadUserData();
    _loadParticipants();
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

  Future<void> _loadParticipants() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // 1. Carregar dados do cache local primeiro
      if (kDebugMode) {
        print('ParticipantsListScreen._loadParticipants: carregando dados do cache local...');
      }
      final cachedParticipants = await _repository.loadFromCache();
      
      // 2. Se o cache estiver vazio, sincronizar com o servidor
      if (cachedParticipants.isEmpty) {
        if (kDebugMode) {
          print('ParticipantsListScreen._loadParticipants: cache vazio, sincronizando com servidor...');
        }
        try {
          final syncedCount = await _repository.syncFromServer();
          if (kDebugMode) {
            print('ParticipantsListScreen._loadParticipants: sincronização concluída, $syncedCount registros aplicados');
          }
        } catch (syncError) {
          if (kDebugMode) {
            print('ParticipantsListScreen._loadParticipants: erro ao sincronizar - $syncError');
          }
        }
      }
      
      // 3. Recarregar dados do cache
      final participants = await _repository.listAll();
      if (mounted) {
        setState(() {
          _participants = participants;
          _loading = false;
        });
        if (kDebugMode) {
          print('ParticipantsListScreen._loadParticipants: UI atualizada com ${participants.length} participantes');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
        if (kDebugMode) {
          print('ParticipantsListScreen._loadParticipants: erro ao carregar - $e');
        }
      }
    }
  }

  Future<void> _showAddParticipantDialog() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Criação de participantes é gerenciada pelo servidor.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _showEditParticipantDialog(Participant participant) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edição de participantes é gerenciada pelo servidor.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _deleteParticipant(String participantId) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Deleção de participantes é gerenciada pelo servidor.'),
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
        title: 'Participantes',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadParticipants,
          ),
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
        onPressed: _showAddParticipantDialog,
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
    if (_participants.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum participante',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadParticipants,
      color: purple,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _participants.length,
        itemBuilder: (context, index) {
          final participant = _participants[index];
          return Dismissible(
            key: Key(participant.id),
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
                    'Tem certeza que deseja remover "${participant.displayName}"?',
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
            onDismissed: (_) => _deleteParticipant(participant.id),
            child: GestureDetector(
              onLongPress: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Gerenciamento de participantes é feito pelo servidor'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ParticipantDetailScreen(
                    participant: participant,
                    onParticipantUpdated: _loadParticipants,
                  ),
                ),
              ),
              child: Card(
              color: slate.withValues(alpha: 0.5),
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: participant.isPremium
                      ? cyan
                      : purple.withValues(alpha: 0.3),
                  child: Text(
                    participant.nickname[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  participant.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      participant.skillLevelText,
                      style: const TextStyle(color: cyan, fontSize: 12),
                    ),
                    Text(
                      participant.badge,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit, color: cyan),
                  onPressed: () => _showEditParticipantDialog(participant),
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
