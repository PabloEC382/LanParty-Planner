import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../core/theme.dart';
import '../../../home/presentation/widgets/app_bar_helper.dart';
import '../../../home/presentation/widgets/complete_drawer_helper.dart';
import '../../../../services/shared_preferences_services.dart';
import '../../domain/entities/game.dart';
import '../../infrastructure/repositories/games_repository_impl.dart';
import '../../infrastructure/local/games_local_dao_shared_prefs.dart';
import '../../infrastructure/remote/supabase_games_remote_datasource.dart';
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
  String? _userName;
  String? _userEmail;
  String? _userPhotoPath;

  @override
  void initState() {
    super.initState();
    _repository = GamesRepositoryImpl(
      remoteApi: SupabaseGamesRemoteDatasource(),
      localDao: GamesLocalDaoSharedPrefs(),
    );
    _loadUserData();
    _loadGames();
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

  Future<void> _loadGames() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // 1. Carregar dados do cache local primeiro (sempre mais rápido)
      if (kDebugMode) {
        print('GamesListScreen._loadGames: carregando dados do cache local...');
      }
      final cachedGames = await _repository.loadFromCache();
      
      // 2. Se o cache estiver vazio, sincronizar com o servidor
      if (cachedGames.isEmpty) {
        if (kDebugMode) {
          print('GamesListScreen._loadGames: cache vazio, sincronizando com servidor...');
        }
        try {
          final syncedCount = await _repository.syncFromServer();
          if (kDebugMode) {
            print('GamesListScreen._loadGames: sincronização concluída, $syncedCount registros aplicados');
          }
        } catch (syncError) {
          if (kDebugMode) {
            print('GamesListScreen._loadGames: erro ao sincronizar - $syncError');
          }
          // Continuar mesmo com erro de sync - pode ser conexão fraca
        }
      }
      
      // 3. Recarregar dados do cache (agora com dados do servidor se foi feito sync)
      if (kDebugMode) {
        print('GamesListScreen._loadGames: carregando dados atualizados do cache...');
      }
      final games = await _repository.listAll();
      
      if (mounted) {
        setState(() {
          _games = games;
          _loading = false;
        });
        if (kDebugMode) {
          print('GamesListScreen._loadGames: UI atualizada com ${games.length} jogos');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
        if (kDebugMode) {
          print('GamesListScreen._loadGames: erro ao carregar - $e');
        }
      }
    }
  }

  Future<void> _showAddGameDialog() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Criação de jogos é gerenciada pelo servidor.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _showEditGameDialog(Game game) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edição de jogos é gerenciada pelo servidor.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _deleteGame(String gameId) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Deleção de jogos é gerenciada pelo servidor.'),
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
        title: 'Jogos',
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadGames),
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
        onLongPress: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gerenciamento de jogos é feito pelo servidor'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        onTap: onTap,
        child: Card(
          color: slate.withValues(alpha: 0.5),
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
                      color: purple.withValues(alpha: 0.3),
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
                    color: purple.withValues(alpha: 0.3),
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
                        color: cyan.withValues(alpha: 0.2),
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
