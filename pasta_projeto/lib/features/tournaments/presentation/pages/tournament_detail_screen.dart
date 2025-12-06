import 'package:flutter/material.dart';
import '../../domain/entities/tournament.dart';
import '../../../core/theme.dart';
import '../../../home/presentation/widgets/app_bar_helper.dart';
import '../../../home/presentation/widgets/complete_drawer_helper.dart';
import '../../../../services/shared_preferences_services.dart';

class TournamentDetailScreen extends StatefulWidget {
  final Tournament tournament;
  final VoidCallback onTournamentUpdated;

  const TournamentDetailScreen({
    required this.tournament,
    required this.onTournamentUpdated,
    super.key,
  });

  @override
  State<TournamentDetailScreen> createState() => _TournamentDetailScreenState();
}

class _TournamentDetailScreenState extends State<TournamentDetailScreen> {
  late Tournament _tournament;
  String? _userName;
  String? _userEmail;
  String? _userPhotoPath;

  @override
  void initState() {
    super.initState();
    _tournament = widget.tournament;
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
        title: 'Detalhes do Torneio',
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
            // Título
            Text(
              _tournament.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Status
            Text(
              _tournament.statusText,
              style: const TextStyle(
                color: cyan,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),

            // Descrição
            if (_tournament.description != null && _tournament.description!.isNotEmpty)
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
                    _tournament.description!,
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
                        'Formato:',
                        style: TextStyle(color: Colors.white70),
                      ),
                      Text(
                        _tournament.formatText,
                        style: const TextStyle(color: cyan, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Participantes:',
                        style: TextStyle(color: Colors.white70),
                      ),
                      Text(
                        '${_tournament.currentParticipants}/${_tournament.maxParticipants}',
                        style: const TextStyle(color: cyan, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Prêmio:',
                        style: TextStyle(color: Colors.white70),
                      ),
                      Text(
                        _tournament.prizeDisplay,
                        style: const TextStyle(color: cyan, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Registro:',
                        style: TextStyle(color: Colors.white70),
                      ),
                      Text(
                        _tournament.canRegister ? 'Aberto' : 'Fechado',
                        style: TextStyle(
                          color: _tournament.canRegister ? Colors.greenAccent : Colors.redAccent,
                          fontWeight: FontWeight.bold,
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
