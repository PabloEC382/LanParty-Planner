import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../providers/domain/entities/tournament.dart';
import '../providers/infrastructure/dtos/tournament_dto.dart';
import '../providers/infrastructure/repositories/tournaments_repository_impl.dart';
import '../providers/infrastructure/local/tournaments_local_dao_shared_prefs.dart';
import '../providers/presentation/dialogs/tournament_form_dialog.dart';

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

  TournamentDto _convertTournamentToDto(Tournament tournament) {
    return TournamentDto(
      id: tournament.id,
      name: tournament.name,
      description: tournament.description,
      game_id: tournament.gameId,
      format: tournament.format.toString().split('.').last,
      status: tournament.status.toString().split('.').last,
      max_participants: tournament.maxParticipants,
      current_participants: tournament.currentParticipants,
      prize_pool: tournament.prizePool,
      start_date: tournament.startDate.toIso8601String(),
      end_date: tournament.endDate?.toIso8601String(),
      organizer_ids: tournament.organizerIds.toList(),
      rules: tournament.rules,
      created_at: tournament.createdAt.toIso8601String(),
      updated_at: tournament.updatedAt.toIso8601String(),
    );
  }

  Future<void> _showAddTournamentDialog() async {
    final result = await showTournamentFormDialog(context);
    if (result != null) {
      try {
        final newTournament = Tournament(
          id: result.id,
          name: result.name,
          description: result.description,
          gameId: result.game_id,
          format: _parseFormat(result.format),
          status: _parseStatus(result.status),
          maxParticipants: result.max_participants,
          currentParticipants: result.current_participants,
          prizePool: result.prize_pool,
          startDate: DateTime.parse(result.start_date),
          endDate: result.end_date != null ? DateTime.parse(result.end_date!) : null,
          organizerIds: (result.organizer_ids ?? []).toSet(),
          rules: result.rules,
          createdAt: DateTime.parse(result.created_at),
          updatedAt: DateTime.parse(result.updated_at),
        );
        
        await _repository.create(newTournament);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Torneio adicionado com sucesso!')),
          );
          _loadTournaments();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao adicionar torneio: $e')),
          );
        }
      }
    }
  }

  Future<void> _showEditTournamentDialog(Tournament tournament) async {
    final tournamentDto = _convertTournamentToDto(tournament);
    final result = await showTournamentFormDialog(context, initial: tournamentDto);
    if (result != null) {
      try {
        final updatedTournament = Tournament(
          id: result.id,
          name: result.name,
          description: result.description,
          gameId: result.game_id,
          format: _parseFormat(result.format),
          status: _parseStatus(result.status),
          maxParticipants: result.max_participants,
          currentParticipants: result.current_participants,
          prizePool: result.prize_pool,
          startDate: DateTime.parse(result.start_date),
          endDate: result.end_date != null ? DateTime.parse(result.end_date!) : null,
          organizerIds: (result.organizer_ids ?? []).toSet(),
          rules: result.rules,
          createdAt: DateTime.parse(result.created_at),
          updatedAt: DateTime.parse(result.updated_at),
        );
        
        await _repository.update(updatedTournament);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Torneio atualizado com sucesso!')),
          );
          _loadTournaments();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao atualizar torneio: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteTournament(String tournamentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Tem certeza que deseja deletar este torneio?'),
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
        await _repository.delete(tournamentId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Torneio deletado com sucesso!')),
          );
          _loadTournaments();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao deletar torneio: $e')),
          );
        }
      }
    }
  }

  TournamentFormat _parseFormat(String format) {
    switch (format.toLowerCase()) {
      case 'double_elimination': return TournamentFormat.doubleElimination;
      case 'round_robin': return TournamentFormat.roundRobin;
      case 'swiss': return TournamentFormat.swiss;
      default: return TournamentFormat.singleElimination;
    }
  }

  TournamentStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'registration': return TournamentStatus.registration;
      case 'in_progress': return TournamentStatus.inProgress;
      case 'finished': return TournamentStatus.finished;
      case 'cancelled': return TournamentStatus.cancelled;
      default: return TournamentStatus.draft;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: slate,
      appBar: AppBar(
        backgroundColor: purple,
        title: const Text('Torneios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTournaments,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTournamentDialog,
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
    if (_tournaments.isEmpty)
      return const Center(
        child: Text('Nenhum torneio', style: TextStyle(color: Colors.white70)),
      );

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
            onDismissed: (_) => _deleteTournament(tournament.id),
            child: Card(
              color: slate.withOpacity(0.5),
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
                      style: TextStyle(color: cyan, fontSize: 12),
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
                  icon: const Icon(Icons.edit, color: Colors.white38),
                  onPressed: () => _showEditTournamentDialog(tournament),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
