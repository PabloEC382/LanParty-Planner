import 'dart:io';

import 'package:flutter/material.dart';
import 'profile_page.dart';
import '../../../../services/shared_preferences_services.dart';
import '../../../core/theme.dart';
import '../../../consent/consent_history_screen.dart';
import '../../../events/presentation/pages/events_list_screen.dart';
import '../../../games/presentation/pages/games_list_screen.dart';
import '../../../tournaments/presentation/pages/tournaments_list_screen.dart';
import '../../../venues/presentation/pages/venues_list_screen.dart';
import '../../../participants/presentation/pages/participants_list_screen.dart';
import '../widgets/tutorial_popup.dart';
import '../widgets/upcoming_events_widget.dart';

class MyHomePage extends StatefulWidget {
  static const routeName = '/home';
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _name;
  String? _email;
  String? _photoPath;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final name = await SharedPreferencesService.getUserName();
    final email = await SharedPreferencesService.getUserEmail();
    final photo = await SharedPreferencesService.getUserPhotoPath();
    if (mounted) {
      setState(() {
        _name = name;
        _email = email;
        _photoPath = photo;
      });
    }
  }

  Widget _buildAvatar() {
    if (_photoPath != null && File(_photoPath!).existsSync()) {
      return CircleAvatar(
        backgroundImage: FileImage(File(_photoPath!)),
      );
    }

    final initials = _name?.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase() ?? '';
    return CircleAvatar(
      backgroundColor: purple,
      child: Text(
        initials,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: slate,
      appBar: AppBar(
        backgroundColor: purple,
        title: const Text('Gamer Event Platform'),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(_name ?? 'Usuário'),
              accountEmail: Text(_email ?? 'Sem e-mail'),
              currentAccountPicture: _buildAvatar(),
              decoration: const BoxDecoration(color: purple),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Perfil'),
              onTap: () async {
                await Navigator.of(context).pushNamed(ProfilePage.routeName);
                _loadUserData(); // Recarrega os dados ao voltar do perfil
              },
            ),
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('Gerenciar Eventos'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const EventsListScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.sports_esports),
              title: const Text('Jogos'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const GamesListScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.emoji_events),
              title: const Text('Torneios'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TournamentsListScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Local'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const VenuesListScreen()),
                );
              },
            ),
                        ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Participantes'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ParticipantsListScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.verified_user),
              title: const Text('Histórico Consentimento'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ConsentHistoryScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('📚 Tutorial'),
              onTap: () {
                Navigator.pop(context); // Fecha o drawer
                TutorialPopup.show(context);
              },
            ),
          ],
        ),
      ),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            // Upcoming Events Widget
            UpcomingEventsWidget(),
            
            // Welcome message
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Bem-vindo!',
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Use o menu para navegar.',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
