import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../policies/listtile_policy_widget.dart';
import '../../policies/policy_viewer_page.dart';

class GoToAcessObPage extends StatefulWidget {
  final VoidCallback onAllAccepted;
  const GoToAcessObPage({super.key, required this.onAllAccepted});

  @override
  State<GoToAcessObPage> createState() => _GoToAcessObPageState();
}

class _GoToAcessObPageState extends State<GoToAcessObPage> {
  bool _privacyRead = false;
  bool _termsRead = false;

  Future<void> _openPolicy(String title, String assetPath, VoidCallback onAgree) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PolicyViewerPage(
          title: title,
          assetPath: assetPath,
          onAgree: () {
          },
        ),
      ),
    );
    if (result == true) {
      setState(() {
        if (title.toLowerCase().contains('priv')) _privacyRead = true;
        if (title.toLowerCase().contains('termo')) _termsRead = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final allAccepted = _privacyRead && _termsRead;
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.verified_user, color: cyan, size: 88),
              const SizedBox(height: 20),
              Text(
                'Tudo pronto para Começar',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Leia e aceite os termos para garantir sua segurança e privacidade.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              PolicyListTile(
                title: 'Política de Privacidade',
                read: _privacyRead,
                onRead: () => _openPolicy('Política de Privacidade', 'assets/privacidade.md', () {}),
              ),
              const SizedBox(height: 12),
              PolicyListTile(
                title: 'Termos de Uso',
                read: _termsRead,
                onRead: () => _openPolicy('Termos de Uso', 'assets/termos.md', () {}),
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: allAccepted ? widget.onAllAccepted : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: purple,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  ),
                  child: const Text('Avançar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}