import 'package:flutter/material.dart';
import '../../domain/entities/venue.dart';
import '../../../core/theme.dart';
import '../../../home/presentation/widgets/app_bar_helper.dart';
import '../../../home/presentation/widgets/complete_drawer_helper.dart';
import '../../../../services/shared_preferences_services.dart';

class VenueDetailScreen extends StatefulWidget {
  final Venue venue;
  final VoidCallback onVenueUpdated;

  const VenueDetailScreen({
    required this.venue,
    required this.onVenueUpdated,
    super.key,
  });

  @override
  State<VenueDetailScreen> createState() => _VenueDetailScreenState();
}

class _VenueDetailScreenState extends State<VenueDetailScreen> {
  late Venue _venue;
  String? _userName;
  String? _userEmail;
  String? _userPhotoPath;

  @override
  void initState() {
    super.initState();
    _venue = widget.venue;
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
        title: 'Detalhes do Local',
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
              _venue.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Local
            Text(
              '${_venue.city} - ${_venue.state}',
              style: const TextStyle(
                color: cyan,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),

            // Endereço
            if (_venue.address.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Endereço',
                    style: TextStyle(
                      color: cyan,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _venue.fullAddress,
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
                        'Capacidade:',
                        style: TextStyle(color: Colors.white70),
                      ),
                      Text(
                        '${_venue.capacity} pessoas (${_venue.capacityCategory})',
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
                        _venue.ratingDisplay,
                        style: const TextStyle(color: cyan, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  if (_venue.facilities.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        const Text(
                          'Instalações:',
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: _venue.facilities
                              .map(
                                (facility) => Chip(
                                  label: Text(facility),
                                  backgroundColor: cyan.withValues(alpha: 0.2),
                                  labelStyle: const TextStyle(color: cyan),
                                ),
                              )
                              .toList(),
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
