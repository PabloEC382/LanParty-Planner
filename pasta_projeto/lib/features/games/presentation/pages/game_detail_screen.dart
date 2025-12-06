import 'package:flutter/material.dart';
import '../../domain/entities/game.dart';
import '../../../core/theme.dart';
import '../../../home/presentation/widgets/app_bar_helper.dart';
import '../../../home/presentation/widgets/complete_drawer_helper.dart';
import '../../../../services/shared_preferences_services.dart';

class GameDetailScreen extends StatefulWidget {
  final Game game;
  final VoidCallback onGameUpdated;

  const GameDetailScreen({
    required this.game,
    required this.onGameUpdated,
    super.key,
  });

  @override
  State<GameDetailScreen> createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen> {
  late Game _game;
  String? _userName;
  String? _userEmail;
  String? _userPhotoPath;

  @override
  void initState() {
    super.initState();
    _game = widget.game;
    _loadUserData();
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

  Future<void> _showEditDialog() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edição é gerenciada pelo servidor.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _showDeleteConfirmation() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Deleção é gerenciada pelo servidor.'),
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
        title: 'Detalhes do Jogo',
      ),
      drawer: buildCompleteDrawer(
        context,
        userName: _userName,
        userEmail: _userEmail,
        userPhotoPath: _userPhotoPath,
        onUserDataUpdated: _loadUserData,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Capa
            if (_game.coverImageUri != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  _game.coverImageUri.toString(),
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: double.infinity,
                    height: 300,
                    color: purple.withValues(alpha: 0.3),
                    child: const Icon(
                      Icons.sports_esports,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  color: purple.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.sports_esports,
                  size: 80,
                  color: Colors.white,
                ),
              ),
            const SizedBox(height: 24),

            // Título
            Text(
              _game.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Gênero
            Text(
              _game.genre,
              style: const TextStyle(
                color: cyan,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),

            // Descrição
            if (_game.description != null && _game.description!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Descrição',
                    style: TextStyle(
                      color: cyan,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _game.description!,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),

            // Informações
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: purple.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: cyan.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Jogadores:',
                        style: TextStyle(color: Colors.white70),
                      ),
                      Text(
                        _game.playerRange,
                        style: const TextStyle(color: cyan, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Avaliação:',
                        style: TextStyle(color: Colors.white70),
                      ),
                      Text(
                        _game.ratingDisplay,
                        style: const TextStyle(color: cyan, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_game.isPopular)
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: cyan.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '🔥 Jogo Popular',
                            style: TextStyle(color: cyan, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Botões de ação
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: purple,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _showEditDialog,
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.withValues(alpha: 0.8),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _showDeleteConfirmation,
                    icon: const Icon(Icons.delete),
                    label: const Text('Deletar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.withValues(alpha: 0.6),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    label: const Text('Fechar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
