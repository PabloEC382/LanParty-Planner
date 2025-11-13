import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../providers/domain/entities/game.dart';
import '../providers/infrastructure/dtos/game_dto.dart';
import '../providers/infrastructure/repositories/games_repository_impl.dart';
import '../providers/infrastructure/local/games_local_dao_shared_prefs.dart';
import '../providers/presentation/dialogs/game_form_dialog.dart';

class GamesListScreen extends StatefulWidget {
  const GamesListScreen({super.key});

  @override
  State<GamesListScreen> createState() => _GamesListScreenState();
}

class _GamesListScreenState extends State<GamesListScreen> {
  List<Game> _games = [];
  bool _loading = true;
  String? _error;
  late GamesRepositoryImpl _repository;

  @override
  void initState() {
    super.initState();
    _repository = GamesRepositoryImpl(localDao: GamesLocalDaoSharedPrefs());
    _loadGames();
  }

  Future<void> _loadGames() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final games = await _repository.listAll();
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

  GameDto _convertGameToDto(Game game) {
    return GameDto(
      id: game.id,
      title: game.title,
      description: game.description,
      cover_image_url: game.coverImageUri?.toString(),
      genre: game.genre,
      min_players: game.minPlayers,
      max_players: game.maxPlayers,
      platforms: game.platforms.toList(),
      average_rating: game.averageRating,
      total_matches: game.totalMatches,
      created_at: game.createdAt.toIso8601String(),
      updated_at: game.updatedAt.toIso8601String(),
    );
  }

  Future<void> _showAddGameDialog() async {
    final result = await showGameFormDialog(context);
    if (result != null) {
      try {
        final newGame = Game(
          id: result.id,
          title: result.title,
          description: result.description,
          coverImageUri: result.cover_image_url != null ? Uri.tryParse(result.cover_image_url!) : null,
          genre: result.genre,
          minPlayers: result.min_players,
          maxPlayers: result.max_players,
          platforms: (result.platforms ?? []).toSet(),
          averageRating: result.average_rating,
          totalMatches: result.total_matches,
          createdAt: DateTime.parse(result.created_at),
          updatedAt: DateTime.parse(result.updated_at),
        );
        
        await _repository.create(newGame);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Jogo adicionado com sucesso!')),
          );
          _loadGames();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao adicionar jogo: $e')),
          );
        }
      }
    }
  }

  Future<void> _showEditGameDialog(Game game) async {
    final gameDto = _convertGameToDto(game);
    final result = await showGameFormDialog(context, initial: gameDto);
    if (result != null) {
      try {
        final updatedGame = Game(
          id: result.id,
          title: result.title,
          description: result.description,
          coverImageUri: result.cover_image_url != null ? Uri.tryParse(result.cover_image_url!) : null,
          genre: result.genre,
          minPlayers: result.min_players,
          maxPlayers: result.max_players,
          platforms: (result.platforms ?? []).toSet(),
          averageRating: result.average_rating,
          totalMatches: result.total_matches,
          createdAt: DateTime.parse(result.created_at),
          updatedAt: DateTime.parse(result.updated_at),
        );
        
        await _repository.update(updatedGame);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Jogo atualizado com sucesso!')),
          );
          _loadGames();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao atualizar jogo: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteGame(String gameId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Tem certeza que deseja deletar este jogo?'),
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
        await _repository.delete(gameId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Jogo deletado com sucesso!')),
          );
          _loadGames();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao deletar jogo: $e')),
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
        title: const Text('Jogos Disponíveis'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadGames),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGameDialog,
        backgroundColor: purple,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: cyan));
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
          return Dismissible(
            key: Key(game.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 16),
              color: Colors.red,
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (_) => _deleteGame(game.id),
            child: _GameCard(
              game: game,
              onEdit: () => _showEditGameDialog(game),
            ),
          );
        },
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final Game game;
  final VoidCallback onEdit;

  const _GameCard({required this.game, required this.onEdit});

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
                    child: const Icon(
                      Icons.sports_esports,
                      color: Colors.white,
                    ),
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
            Text(game.genre, style: TextStyle(color: cyan, fontSize: 12)),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
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
        trailing: IconButton(
          icon: const Icon(Icons.edit, color: Colors.white38),
          onPressed: onEdit,
        ),
      ),
    );
  }
}
