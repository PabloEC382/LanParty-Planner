import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../home/presentation/widgets/app_bar_helper.dart';
import '../../../home/presentation/widgets/drawer_helper.dart';
import '../../domain/entities/tournament.dart';
import '../../infrastructure/repositories/tournaments_repository_impl.dart';
import '../../infrastructure/local/tournaments_local_dao_shared_prefs.dart';
import '../dialogs/tournament_form_dialog.dart';
import '../dialogs/tournament_actions_dialog.dart';
import '../../infrastructure/mappers/tournament_mapper.dart';
import 'tournament_detail_screen.dart';

class TournamentsListScreen extends StatefulWidget {
  const TournamentsListScreen({super.key});

  @override
  State<TournamentsListScreen> createState() => _TournamentsListScreenState();
}

class _TournamentsListScreenState extends State<TournamentsListScreen> {
  List<Tournament> _tournaments = [];
  bool _loading = true;
  String? _error;
  late TournamentsRepositoryImpl _repository;

  @override
  void initState() {
    super.initState();
    _repository = TournamentsRepositoryImpl(localDao: TournamentsLocalDaoSharedPrefs());
    _loadTournaments();
  }

  Future<void> _loadTournaments() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final tournaments = await _repository.listAll();
      setState(() {
        _tournaments = tournaments;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _showAddTournamentDialog() async {
    final result = await showTournamentFormDialog(context);
    if (result != null && mounted) {
      try {
        final tournament = TournamentMapper.toEntity(result);
        await _repository.create(tournament);
        await _loadTournaments();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Torneio adicionado com sucesso!')),
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

  Future<void> _showEditTournamentDialog(Tournament tournament) async {
    final dto = TournamentMapper.toDto(tournament);
    final result = await showTournamentFormDialog(context, initial: dto);
    if (result != null && mounted) {
      try {
        final updatedTournament = TournamentMapper.toEntity(result);
        await _repository.update(updatedTournament);
        await _loadTournaments();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Torneio atualizado com sucesso!')),
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

  Future<void> _deleteTournament(String tournamentId) async {
    try {
      await _repository.delete(tournamentId);
      await _loadTournaments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Torneio deletado com sucesso!')),
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
      appBar: buildAppBarWithHome(
        context,
        title: 'Torneios',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTournaments,
          ),
        ],
      ),
      drawer: buildTutorialDrawer(context, children: const []),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: cyan,
        onPressed: _showAddTournamentDialog,
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
    if (_tournaments.isEmpty) {
      return const Center(
        child: Text('Nenhum torneio', style: TextStyle(color: Colors.white70)),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTournaments,
      color: purple,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _tournaments.length,
        itemBuilder: (context, index) {
          final tournament = _tournaments[index];
          return Dismissible(
            key: Key(tournament.id),
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
                    'Tem certeza que deseja remover "${tournament.name}"?',
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
            onDismissed: (_) => _deleteTournament(tournament.id),
            child: GestureDetector(
              onLongPress: () => showTournamentActionsDialog(
                context,
                tournament: tournament,
                onEdit: () => _showEditTournamentDialog(tournament),
                onDelete: () => _deleteTournament(tournament.id),
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TournamentDetailScreen(
                    tournament: tournament,
                    onTournamentUpdated: _loadTournaments,
                  ),
                ),
              ),
              child: Card(
              color: slate.withValues(alpha: 0.5),
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Icon(
                  Icons.emoji_events,
                  color: tournament.canRegister ? cyan : Colors.white38,
                  size: 40,
                ),
                title: Text(
                  tournament.name,
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
                      tournament.statusText,
                      style: const TextStyle(color: cyan, fontSize: 12),
                    ),
                    Text(
                      tournament.formatText,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Text(
                      '${tournament.currentParticipants}/${tournament.maxParticipants} participantes',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Text(
                      tournament.prizeDisplay,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit, color: cyan),
                  onPressed: () => _showEditTournamentDialog(tournament),
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
