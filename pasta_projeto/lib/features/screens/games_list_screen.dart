import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../providers/domain/entities/game.dart';
import '../providers/infrastructure/repositories/games_repository.dart';

class GamesListScreen extends StatefulWidget {
  const GamesListScreen({super.key});

  @override
  State<GamesListScreen> createState() => _GamesListScreenState();
}

class _GamesListScreenState extends State<GamesListScreen> {
  final _repository = GamesRepository();
  List<Game> _games = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  Future<void> _loadGames() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final games = await _repository.getAllGames();
      setState(() {
        _games = games;
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
        title: const Text('Jogos Disponíveis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadGames,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
        },
        backgroundColor: purple,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: cyan),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar jogos',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadGames,
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    if (_games.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videogame_asset_off, size: 64, color: Colors.white38),
            const SizedBox(height: 16),
            const Text(
              'Nenhum jogo cadastrado',
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadGames,
      color: purple,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _games.length,
        itemBuilder: (context, index) {
          final game = _games[index];
          return _GameCard(game: game);
        },
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final Game game;

  const _GameCard({required this.game});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: slate.withOpacity(0.5),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: game.coverImageUri != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  game.coverImageUri.toString(),
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 60,
                    height: 60,
                    color: purple.withOpacity(0.3),
                    child: const Icon(Icons.sports_esports, color: Colors.white),
                  ),
                ),
              )
            : Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: purple.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.sports_esports, color: Colors.white),
              ),
        title: Text(
          game.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              game.genre,
              style: TextStyle(color: cyan, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              game.playerRange,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  game.ratingDisplay,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(width: 12),
                if (game.isPopular)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: cyan.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '🔥 Popular',
                      style: TextStyle(color: cyan, fontSize: 10),
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 16),
        onTap: () {
          // TODO: Navegar para detalhes do jogo
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Detalhes de ${game.title}')),
          );
        },
      ),
    );
  }
}