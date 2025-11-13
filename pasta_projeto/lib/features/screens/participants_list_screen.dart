import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../providers/domain/entities/participant.dart';
import '../providers/infrastructure/dtos/participant_dto.dart';
import '../providers/infrastructure/repositories/participants_repository_impl.dart';
import '../providers/infrastructure/local/participants_local_dao_shared_prefs.dart';
import '../providers/presentation/dialogs/participant_form_dialog.dart';

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

  @override
  void initState() {
    super.initState();
    _repository = ParticipantsRepositoryImpl(localDao: ParticipantsLocalDaoSharedPrefs());
    _loadParticipants();
  }

  Future<void> _loadParticipants() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final participants = await _repository.listAll();
      setState(() {
        _participants = participants;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  ParticipantDto _convertParticipantToDto(Participant participant) {
    return ParticipantDto(
      id: participant.id,
      name: participant.name,
      email: participant.email,
      nickname: participant.nickname,
      avatar_url: participant.avatarUri?.toString(),
      skill_level: participant.skillLevel,
      preferred_games: participant.preferredGames.toList(),
      is_premium: participant.isPremium,
      registered_at: participant.registeredAt.toIso8601String(),
      updated_at: participant.updatedAt.toIso8601String(),
    );
  }

  Future<void> _showAddParticipantDialog() async {
    final result = await showParticipantFormDialog(context);
    if (result != null) {
      try {
        final newParticipant = Participant(
          id: result.id,
          name: result.name,
          email: result.email,
          nickname: result.nickname,
          skillLevel: result.skill_level,
          avatarUri: result.avatar_url != null ? Uri.tryParse(result.avatar_url!) : null,
          isPremium: result.is_premium,
          preferredGames: (result.preferred_games ?? []).toSet(),
          registeredAt: DateTime.parse(result.registered_at),
          updatedAt: DateTime.parse(result.updated_at),
        );
        
        await _repository.create(newParticipant);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Participante adicionado com sucesso!')),
          );
          _loadParticipants();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao adicionar participante: $e')),
          );
        }
      }
    }
  }

  Future<void> _showEditParticipantDialog(Participant participant) async {
    final participantDto = _convertParticipantToDto(participant);
    final result = await showParticipantFormDialog(context, initial: participantDto);
    if (result != null) {
      try {
        final updatedParticipant = Participant(
          id: result.id,
          name: result.name,
          email: result.email,
          nickname: result.nickname,
          skillLevel: result.skill_level,
          avatarUri: result.avatar_url != null ? Uri.tryParse(result.avatar_url!) : null,
          isPremium: result.is_premium,
          preferredGames: (result.preferred_games ?? []).toSet(),
          registeredAt: DateTime.parse(result.registered_at),
          updatedAt: DateTime.parse(result.updated_at),
        );
        
        await _repository.update(updatedParticipant);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Participante atualizado com sucesso!')),
          );
          _loadParticipants();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao atualizar participante: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteParticipant(String participantId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Tem certeza que deseja deletar este participante?'),
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
        await _repository.delete(participantId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Participante deletado com sucesso!')),
          );
          _loadParticipants();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao deletar participante: $e')),
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
        title: const Text('Participantes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadParticipants,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddParticipantDialog,
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
    if (_participants.isEmpty)
      return const Center(
        child: Text(
          'Nenhum participante',
          style: TextStyle(color: Colors.white70),
        ),
      );

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
            onDismissed: (_) => _deleteParticipant(participant.id),
            child: Card(
              color: slate.withOpacity(0.5),
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: participant.isPremium
                      ? cyan
                      : purple.withOpacity(0.3),
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
                      style: TextStyle(color: cyan, fontSize: 12),
                    ),
                    Text(
                      participant.badge,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white38),
                  onPressed: () => _showEditParticipantDialog(participant),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
