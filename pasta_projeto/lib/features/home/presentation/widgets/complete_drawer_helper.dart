import 'dart:io';
import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import '../../../core/theme.dart';
import '../../../core/theme_controller.dart';
import '../../../consent/consent_history_screen.dart';
import '../../../events/presentation/pages/events_list_screen.dart';
import '../../../games/presentation/pages/games_list_screen.dart';
import '../../../tournaments/presentation/pages/tournaments_list_screen.dart';
import '../../../venues/presentation/pages/venues_list_screen.dart';
import '../../../participants/presentation/pages/participants_list_screen.dart';
import '../../../../services/theme_service.dart';
import 'tutorial_popup.dart';

/// Constrói um Drawer completo com todas as opções de navegação e toggle de tema
Widget buildCompleteDrawer(
  BuildContext context, {
  required String? userName,
  required String? userEmail,
  required String? userPhotoPath,
  required VoidCallback onUserDataUpdated,
  ThemeController? themeController,
}) {
  // Se não receber controller, usa o global
  final controller = themeController ?? ThemeService.instance;

  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        UserAccountsDrawerHeader(
          accountName: Text(userName ?? 'Usuário'),
          accountEmail: Text(userEmail ?? 'Sem e-mail'),
          currentAccountPicture: _buildAvatar(userName, userPhotoPath),
          decoration: const BoxDecoration(color: purple),
        ),
        ListTile(
          leading: const Icon(Icons.person),
          title: const Text('Perfil'),
          onTap: () async {
            Navigator.of(context).pop();
            await Navigator.of(context).pushNamed('/profile');
            onUserDataUpdated();
          },
        ),
        ListTile(
          leading: const Icon(Icons.home),
          title: const Text('Home'),
          onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacementNamed(MyHomePage.routeName);
          },
        ),
        ListTile(
          leading: const Icon(Icons.event),
          title: const Text('Gerenciar Eventos'),
          onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const EventsListScreen()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.sports_esports),
          title: const Text('Jogos'),
          onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const GamesListScreen()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.emoji_events),
          title: const Text('Torneios'),
          onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TournamentsListScreen()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.location_on),
          title: const Text('Local'),
          onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const VenuesListScreen()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.people),
          title: const Text('Participantes'),
          onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ParticipantsListScreen()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.verified_user),
          title: const Text('Histórico Consentimento'),
          onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ConsentHistoryScreen()),
            );
          },
        ),
        const Divider(),
        // ========== TOGGLE DE TEMA ==========
        _buildThemeToggle(context, controller),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.help_outline),
          title: const Text('📚 Tutorial'),
          onTap: () {
            Navigator.pop(context);
            TutorialPopup.show(context);
          },
        ),
      ],
    ),
  );
}

/// Constrói o widget de toggle de tema
Widget _buildThemeToggle(BuildContext context, ThemeController themeController) {
  final brightness = MediaQuery.platformBrightnessOf(context);
  final isDark = themeController.mode == ThemeMode.dark ||
      (themeController.mode == ThemeMode.system && brightness == Brightness.dark);

  return SwitchListTile(
    secondary: Icon(
      isDark ? Icons.dark_mode : Icons.light_mode_outlined,
    ),
    title: const Text('Tema escuro'),
    subtitle: Text(
      themeController.isSystemMode
          ? 'Seguindo o sistema'
          : (isDark ? 'Ativado' : 'Desativado'),
    ),
    value: isDark,
    onChanged: (value) async {
      await themeController.toggle(brightness);
    },
  );
}

Widget _buildAvatar(String? userName, String? photoPath) {
  if (photoPath != null && File(photoPath).existsSync()) {
    return CircleAvatar(
      backgroundImage: FileImage(File(photoPath)),
    );
  }

  final initials = userName?.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase() ?? '';
  return CircleAvatar(
    backgroundColor: purple,
    child: Text(
      initials,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
  );
}
