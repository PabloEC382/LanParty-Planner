import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../domain/entities/participant.dart';
import '../../infrastructure/repositories/participants_repository_impl.dart';
import '../../infrastructure/local/participants_local_dao_shared_prefs.dart';
import '../dialogs/participant_form_dialog.dart';
import '../dialogs/participant_actions_dialog.dart';
import '../../infrastructure/mappers/participant_mapper.dart';
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

  Future<void> _showAddParticipantDialog() async {
    final result = await showParticipantFormDialog(context);
    if (result != null && mounted) {
      try {
        final participant = ParticipantMapper.toEntity(result);
        await _repository.create(participant);
        await _loadParticipants();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Participante adicionado com sucesso!')),
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

  Future<void> _showEditParticipantDialog(Participant participant) async {
    final dto = ParticipantMapper.toDto(participant);
    final result = await showParticipantFormDialog(context, initial: dto);
    if (result != null && mounted) {
      try {
        final updatedParticipant = ParticipantMapper.toEntity(result);
        await _repository.update(updatedParticipant);
        await _loadParticipants();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Participante atualizado com sucesso!')),
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

  Future<void> _deleteParticipant(String participantId) async {
    try {
      await _repository.delete(participantId);
      await _loadParticipants();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Participante deletado com sucesso!')),
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
              onLongPress: () => showParticipantActionsDialog(
                context,
                participant: participant,
                onEdit: () => _showEditParticipantDialog(participant),
                onDelete: () => _deleteParticipant(participant.id),
              ),
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
