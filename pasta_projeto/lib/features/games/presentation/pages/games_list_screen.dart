import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../domain/entities/game.dart';
import '../../infrastructure/repositories/games_repository_impl.dart';
import '../../infrastructure/local/games_local_dao_shared_prefs.dart';
import '../dialogs/game_form_dialog.dart';
import '../dialogs/game_actions_dialog.dart';
import '../../infrastructure/mappers/game_mapper.dart';
import 'game_detail_screen.dart';

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

  Future<void> _showAddGameDialog() async {
    final result = await showGameFormDialog(context);
    if (result != null && mounted) {
      try {
        final game = GameMapper.toEntity(result);
        await _repository.create(game);
        await _loadGames();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Jogo adicionado com sucesso!')),
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

  Future<void> _showEditGameDialog(Game game) async {
    final dto = GameMapper.toDto(game);
    final result = await showGameFormDialog(context, initial: dto);
    if (result != null && mounted) {
      try {
        final updatedGame = GameMapper.toEntity(result);
        await _repository.update(updatedGame);
        await _loadGames();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Jogo atualizado com sucesso!')),
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

  Future<void> _deleteGame(String gameId) async {
    try {
      await _repository.delete(gameId);
      await _loadGames();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Jogo deletado com sucesso!')),
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
        title: const Text('Jogos Disponíveis'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadGames),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: cyan,
        onPressed: _showAddGameDialog,
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            const Text(
              'Erro ao carregar jogos',
              style: TextStyle(color: Colors.white, fontSize: 18),
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
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videogame_asset_off, size: 64, color: Colors.white38),
            SizedBox(height: 16),
            Text(
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
          return _GameCard(
            game: game,
            onEdit: () => _showEditGameDialog(game),
            onDelete: () => _deleteGame(game.id),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GameDetailScreen(
                  game: game,
                  onGameUpdated: _loadGames,
                ),
              ),
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
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _GameCard({
    required this.game,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(game.id),
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
              'Tem certeza que deseja remover "${game.title}"?',
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
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onLongPress: () => showGameActionsDialog(
          context,
          game: game,
          onEdit: onEdit,
          onDelete: onDelete,
        ),
        onTap: onTap,
        child: Card(
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
              Text(game.genre, style: const TextStyle(color: cyan, fontSize: 12)),
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
            icon: const Icon(Icons.edit, color: cyan),
            onPressed: onEdit,
          ),
        ),
      ),
      ),
    );
  }
}
