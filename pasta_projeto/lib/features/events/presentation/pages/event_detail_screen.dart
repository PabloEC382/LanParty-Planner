import 'package:flutter/material.dart';
import '../../domain/entities/event.dart';
import '../../../core/theme.dart';
import '../../../home/presentation/widgets/app_bar_helper.dart';
import '../../../home/presentation/widgets/complete_drawer_helper.dart';
import '../../../../services/shared_preferences_services.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;
  final VoidCallback onEventUpdated;

  const EventDetailScreen({
    required this.event,
    required this.onEventUpdated,
    super.key,
  });

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late Event _event;
  String? _userName;
  String? _userEmail;
  String? _userPhotoPath;

  @override
  void initState() {
    super.initState();
    _event = widget.event;
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
        title: 'Detalhes do Evento',
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
              _event.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Descrição
            if (_event.description.isNotEmpty)
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
                    _event.description,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),

            // Data e Hora
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Data e Hora',
                  style: TextStyle(
                    color: cyan,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: purple.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: cyan.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Início: ${_event.startDate.toLocal().toString().split('.')[0]} às ${_event.startTime}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Fim: ${_event.endDate.toLocal().toString().split('.')[0]} às ${_event.endTime}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),

            // Local
            if (_event.venueId != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Local',
                    style: TextStyle(
                      color: cyan,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: purple.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: cyan.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      _event.venueId ?? 'Não definido',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),

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
