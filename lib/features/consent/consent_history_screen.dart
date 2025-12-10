import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme.dart';
import '../onboarding/onboarding_page.dart';

class ConsentHistoryScreen extends StatefulWidget {
  const ConsentHistoryScreen({super.key});

  @override
  State<ConsentHistoryScreen> createState() => _ConsentHistoryScreenState();
}

class _ConsentHistoryScreenState extends State<ConsentHistoryScreen> {
  bool _accepted = false;
  String? _infoHash;
  DateTime? _date;

  @override
  void initState() {
    super.initState();
    _loadConsent();
  }

  Future<void> _loadConsent() async {
    final prefs = await SharedPreferences.getInstance();
    final accepted = prefs.getBool('consent_accepted') ?? false;
    final hash = prefs.getString('consent_info');
    final millis = prefs.getInt('consent_date');
    setState(() {
      _accepted = accepted;
      _infoHash = hash;
      _date = millis != null ? DateTime.fromMillisecondsSinceEpoch(millis) : null;
    });
  }

  Future<void> _revokeConsent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', false);
    await prefs.setBool('consent_accepted', false);
    await prefs.remove('consent_info');
    await prefs.remove('consent_date');
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(OnboardingPage.routeName);
  }

  void _confirmRevoke() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: slate,
        title: const Text('Revogar consentimento', style: TextStyle(color: purple)),
        content: const Text(
          'Tem certeza que deseja revogar o consentimento? Você será redirecionado para o início.',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar', style: TextStyle(color: Color(0xFFFBBF24)))),
          TextButton(onPressed: () { Navigator.of(ctx).pop(); _revokeConsent(); }, child: const Text('Revogar', style: TextStyle(color: purple))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: purple,
        title: const Text('Histórico de Consentimento'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.verified_user, color: Color(0xFFFBBF24), size: 60),
            const SizedBox(height: 16),
            Text('Status atual:', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              _accepted ? 'Consentimento ACEITO' : 'Consentimento NÃO ACEITO',
              style: TextStyle(
                color: _accepted ? const Color(0xFFFBBF24) : Colors.redAccent,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 24),
            if (_infoHash != null) ...[
              const Text('Informação registrada:', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              Text('Hash: $_infoHash', style: const TextStyle(color: Colors.white38, fontSize: 12)),
              const SizedBox(height: 8),
              if (_date != null) Text('Data: ${_date.toString()}', style: const TextStyle(color: Colors.white70)),
            ] else
              const Text('Nenhum consentimento registrado.', style: TextStyle(color: Colors.white70)),
            const Spacer(),
            if (_accepted)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: purple,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  icon: const Icon(Icons.cancel),
                  label: const Text('Revogar Consentimento'),
                  onPressed: _confirmRevoke,
                ),
              ),
          ],
        ),
      ),
    );
  }
}