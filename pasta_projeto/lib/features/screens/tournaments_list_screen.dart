import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../providers/domain/entities/tournament.dart';

class TournamentsListScreen extends StatefulWidget {
  const TournamentsListScreen({super.key});

  @override
  State<TournamentsListScreen> createState() => _TournamentsListScreenState();
}

class _TournamentsListScreenState extends State<TournamentsListScreen> {
  List<Tournament> _tournaments = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTournaments();
  }

  Future<void> _loadTournaments() async {
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
        title: const Text('Torneios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTournaments,
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
          return Card(
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
