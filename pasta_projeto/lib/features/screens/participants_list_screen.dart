import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../providers/domain/entities/participant.dart';

class ParticipantsListScreen extends StatefulWidget {
  const ParticipantsListScreen({super.key});

  @override
  State<ParticipantsListScreen> createState() => _ParticipantsListScreenState();
}

class _ParticipantsListScreenState extends State<ParticipantsListScreen> {
  List<Participant> _participants = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadParticipants();
  }

  Future<void> _loadParticipants() async {
    setState(() {
      _loading = true;
      _error = null;
    });
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
          return Card(
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
              trailing: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white38,
                size: 16,
              ),
            ),
          );
        },
      ),
    );
  }
}
