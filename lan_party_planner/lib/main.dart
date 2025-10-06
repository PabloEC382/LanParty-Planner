import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'dart:convert' show utf8, base64Encode, base64Decode;

// Função global para criptografia
String encryptData(String data, {String key = 'lanparty-key'}) {
  final bytes = utf8.encode('$data$key');
  final digest = sha256.convert(bytes);
  return base64Encode(digest.bytes);
}

void main() {
  runApp(const MyApp());
}

const Color purple = Color(0xFF7C3AED);
const Color cyan = Color(0xFF06B6D4);
const Color slate = Color(0xFF0F172A);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gamer Event Platform',
      theme: ThemeData(
        colorScheme: ColorScheme(
          brightness: Brightness.dark,
          primary: purple,
          onPrimary: Colors.white,
          secondary: cyan,
          onSecondary: Colors.white,
          surface: slate,
          onSurface: Colors.white,
          error: Colors.red,
          onError: Colors.white,
        ),
        scaffoldBackgroundColor: slate,
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
          bodyMedium: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// SplashScreen exibido na primeira execução
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkFirstRun();
  }

  Future<void> _checkFirstRun() async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('onboarding_done') ?? false;
    Timer(const Duration(milliseconds: 2500), () {
      if (onboardingDone) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MyHomePage()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: slate,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo centralizada
            Image.asset(
              'PNGs/logoIASemfundo.png',
              width: 160,
              height: 160,
            ),
            const SizedBox(height: 32),
            Text(
              'GAMER EVENT PLATFORM',
              style: TextStyle(
                color: purple,
                fontWeight: FontWeight.bold,
                fontSize: 28,
                letterSpacing: 2,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Onboarding com persistência local
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentPage = 0;
  bool _consentAccepted = false;
  DateTime? _consentDate;
  final String _termsVersion = "1.0.0"; // Versão do termo

  String? _consentError;
  String? _consentSuccess;

  // Função utilitária para criptografar dados sensíveis (simples, para exemplo)
  String encryptData(String data, {String key = 'lanparty-key'}) {
    // Gera um hash SHA256 do dado + chave e codifica em base64
    final bytes = utf8.encode('$data$key');
    final digest = sha256.convert(bytes);
    return base64Encode(digest.bytes);
  }

  // Função utilitária para "descriptografar" (apenas para simulação, pois SHA256 é irreversível)
  // Em produção, use uma biblioteca de criptografia simétrica (ex: AES).
  bool verifyEncrypted(String data, String encrypted, {String key = 'lanparty-key'}) {
    return encryptData(data, key: key) == encrypted;
  }

  Future<void> _saveOnboardingData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    await prefs.setBool('consent_accepted', _consentAccepted);

    // Criptografa registro do consentimento (data/hora, versão)
    if (_consentAccepted) {
      _consentDate = DateTime.now();
      final consentInfo = jsonEncode({
        'accepted': true,
        'date': _consentDate!.toIso8601String(),
        'version': _termsVersion,
      });
      final encryptedConsent = encryptData(consentInfo);
      await prefs.setString('consent_info', encryptedConsent);

      // Simulação de persistência no backend (substitua por chamada real)
      await _sendConsentToBackend(encryptedConsent);

      setState(() {
        _consentSuccess = "Consentimento registrado com sucesso!";
        _consentError = null;
      });
    }
  }

  // Simulação de envio para backend
  Future<void> _sendConsentToBackend(String consentInfo) async {
    // Aqui você faria uma chamada HTTP real para o backend
    await Future.delayed(const Duration(milliseconds: 500));
    // print("Consentimento enviado ao backend: $consentInfo");
  }

  void _nextPage() {
    // Impede avanço sem consentimento na última tela
    if (_currentPage == 3 && !_consentAccepted) {
      setState(() {
        _consentError = "Você precisa aceitar os termos para continuar.";
        _consentSuccess = null;
      });
      return;
    }
    setState(() {
      _consentError = null;
      _consentSuccess = null;
      if (_currentPage < 3) _currentPage++;
    });
  }

  void _prevPage() {
    setState(() {
      if (_currentPage > 0) _currentPage--;
    });
  }

  void _skipToConsent() {
    setState(() {
      _currentPage = 3;
    });
  }

  Future<void> _finishOnboarding() async {
    await _saveOnboardingData();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MyHomePage()),
    );
  }

  Widget _buildDotsIndicator() {
    if (_currentPage == 3) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: index == _currentPage ? purple : Colors.white24,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      // Tela 1: Boas-vindas
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('PNGs/logoIASemfundo.png', width: 120, height: 120),
          const SizedBox(height: 24),
          Text(
            'Bem-vindo!',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Organize mini-eventos gamers com facilidade.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
      // Tela 2: Sobre o aplicativo
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, color: cyan, size: 80),
          const SizedBox(height: 24),
          Text(
            'O que é o Gamer Event Platform?',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Crie eventos, marque tarefas e acompanhe o progresso do seu mini-evento gamer com checklist e horários!',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
      // Tela 3: Tudo pronto!
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.celebration, color: cyan, size: 80),
          const SizedBox(height: 24),
          Text(
            'Tudo pronto!',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Vamos começar a organizar seu evento gamer!',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
      // Tela 4: Política e Consentimento
      SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified_user, color: cyan, size: 80),
            const SizedBox(height: 24),
            Text(
              'Consentimento',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  Text(
                    'Para usar o app, você precisa aceitar os termos de uso e política de privacidade.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  // Exibição dos termos (simples, pode ser expandido)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Termos de Uso - v$_termsVersion',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ao utilizar este aplicativo, você concorda com os termos de uso e política de privacidade. Seus dados serão utilizados apenas para fins de funcionamento do app e nunca compartilhados sem autorização.',
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: slate,
                                title: const Text('Política de Privacidade', style: TextStyle(color: cyan)),
                                content: const Text(
                                  'Sua privacidade é importante. Nenhum dado pessoal será compartilhado com terceiros. Você pode revogar o consentimento a qualquer momento nas configurações.',
                                  style: TextStyle(color: Colors.white),
                                ),
                                actions: [
                                  TextButton(
                                    child: const Text('Fechar', style: TextStyle(color: purple)),
                                    onPressed: () => Navigator.of(context).pop(),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: const Text(
                            'Ver política de privacidade',
                            style: TextStyle(
                              color: cyan,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            CheckboxListTile(
              title: Text(
                'Eu aceito os termos de uso e política de privacidade.',
                style: TextStyle(
                  color: _consentAccepted ? cyan : Colors.white,
                  fontWeight: _consentAccepted ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              value: _consentAccepted,
              activeColor: purple,
              onChanged: (val) {
                setState(() {
                  _consentAccepted = val ?? false;
                  if (_consentAccepted) {
                    _consentDate = DateTime.now();
                    _consentSuccess = "Consentimento aceito!";
                    _consentError = null;
                  } else {
                    _consentDate = null;
                    _consentSuccess = null;
                    _consentError = "Você precisa aceitar os termos para continuar.";
                  }
                });
              },
            ),
            if (_consentAccepted && _consentDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Aceito em: ${DateFormat('dd/MM/yyyy HH:mm').format(_consentDate!)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
            if (_consentError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _consentError!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 15),
                  textAlign: TextAlign.center,
                ),
              ),
            if (_consentSuccess != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _consentSuccess!,
                  style: const TextStyle(color: Colors.greenAccent, fontSize: 15),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: slate,
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: pages[_currentPage],
                  ),
                  const SizedBox(height: 32),
                  _buildDotsIndicator(),
                ],
              ),
            ),
          ),
          // Botões centralizados na parte inferior
          Positioned(
            left: 0,
            right: 0,
            bottom: 32,
            child: Column(
              children: [
                // Telas intermediárias: "Voltar" e "Pular" centralizados acima do "Avançar"
                if (_currentPage == 1 || _currentPage == 2) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Focus(
                        child: Semantics(
                          button: true,
                          label: 'Voltar',
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: slate,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(100, 40),
                            ),
                            onPressed: _prevPage,
                            child: const Text('Voltar'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Focus(
                        child: Semantics(
                          button: true,
                          label: 'Pular',
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: cyan,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(100, 40),
                            ),
                            onPressed: _skipToConsent,
                            child: const Text('Pular'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Focus(
                      child: Semantics(
                        button: true,
                        label: 'Avançar',
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: purple,
                            minimumSize: const Size(180, 48),
                          ),
                          onPressed: _nextPage,
                          child: const Text(
                            'Avançar',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                // Primeira tela: "Pular" centralizado acima do "Avançar"
                if (_currentPage == 0) ...[
                  Center(
                    child: Focus(
                      child: Semantics(
                        button: true,
                        label: 'Pular',
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cyan,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(100, 40),
                          ),
                          onPressed: _skipToConsent,
                          child: const Text('Pular'),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Focus(
                      child: Semantics(
                        button: true,
                        label: 'Avançar',
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: purple,
                            minimumSize: const Size(180, 48),
                          ),
                          onPressed: _nextPage,
                          child: const Text(
                            'Avançar',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                // Tela do consentimento: "Voltar" centralizado acima do "Consentir"
                if (_currentPage == 3) ...[
                  const SizedBox(height: 24), // Espaço extra para afastar os botões do texto
                  Center(
                    child: Focus(
                      child: Semantics(
                        button: true,
                        label: 'Voltar',
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: slate,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(100, 40),
                          ),
                          onPressed: _prevPage,
                          child: const Text('Voltar'),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Focus(
                      child: Semantics(
                        button: true,
                        enabled: _consentAccepted,
                        label: 'Consentir',
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _consentAccepted
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.surface.withOpacity(0.5),
                            minimumSize: const Size(180, 48),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: _consentAccepted
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.white24,
                                width: 2,
                              ),
                            ),
                            elevation: _consentAccepted ? 2 : 0,
                          ),
                          onPressed: _consentAccepted ? _finishOnboarding : null,
                          child: const Text(
                            'Consentir',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _canAccess = false;

  // Adicione as variáveis e métodos do checklist que estavam ausentes
  final List<bool> _checklistStatus = [true, false, false, true];
  final List<String> _checklistItems = [
    'Montar setup',
    'Comprar snacks',
    'Testar conexão',
    'Definir jogos',
  ];

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    final prefs = await SharedPreferences.getInstance();
    final consent = prefs.getBool('consent_accepted') ?? false;
    setState(() {
      _canAccess = consent;
    });
    if (!consent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      });
    }
  }

  Future<void> _revokeConsent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', false);
    await prefs.setBool('consent_accepted', false);
    await prefs.remove('consent_info');
    setState(() {
      _canAccess = false;
    });
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const OnboardingScreen()),
    );
  }

  void _showRevokeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: slate,
        title: Text('Revogar Consentimento', style: TextStyle(color: purple)),
        content: const Text(
          'Tem certeza que deseja revogar o consentimento? Você será redirecionado para o início do app.',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar', style: TextStyle(color: cyan)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Revogar', style: TextStyle(color: purple)),
            onPressed: () {
              Navigator.of(context).pop();
              _revokeConsent();
            },
          ),
        ],
      ),
    );
  }

  // Adicione o checklistItem que estava ausente
  Widget checklistItem(String text, bool checked, VoidCallback onTap) {
    return Focus(
      child: Semantics(
        checked: checked,
        label: text,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Row(
              children: [
                Icon(
                  checked ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: checked
                      ? Theme.of(context).colorScheme.primary
                      : Colors.white,
                  size: 32,
                ),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                    decoration: checked ? TextDecoration.lineThrough : null,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Adicione as actions do AppBar que estavam ausentes
    return Scaffold(
      appBar: AppBar(
        backgroundColor: purple,
        title: const Text('Gamer Event Platform'),
        centerTitle: true,
        actions: [
          Focus(
            child: Semantics(
              button: true,
              label: 'Histórico de Consentimento',
              child: IconButton(
                icon: Icon(Icons.history, color: cyan),
                tooltip: 'Histórico de Consentimento',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const ConsentHistoryScreen()),
                  );
                },
              ),
            ),
          ),
          Focus(
            child: Semantics(
              button: true,
              label: 'Revogar Consentimento',
              child: IconButton(
                icon: Icon(Icons.logout, color: cyan),
                tooltip: 'Revogar Consentimento',
                onPressed: _showRevokeDialog,
              ),
            ),
          ),
          Focus(
            child: Semantics(
              button: true,
              label: 'Eventos',
              child: IconButton(
                icon: Icon(Icons.event, color: cyan),
                tooltip: 'Eventos',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const EventCrudScreen()),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: _canAccess
          ? Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset(
                    'PNGs/logoIASemfundo.png',
                    width: 120,
                    height: 120,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Mini-evento de Sábado',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Horário: 15:00 - 22:00',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  Card(
                    color: slate,
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Checklist',
                            style: TextStyle(
                              color: cyan,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...List.generate(_checklistItems.length, (index) {
                            return checklistItem(
                              _checklistItems[index],
                              _checklistStatus[index],
                              () {
                                setState(() {
                                  _checklistStatus[index] = !_checklistStatus[index];
                                });
                              },
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Focus(
                    child: Semantics(
                      button: true,
                      label: 'Revogar Consentimento',
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: purple,
                          minimumSize: const Size(180, 48),
                        ),
                        icon: const Icon(Icons.logout, color: Colors.white),
                        label: const Text(
                          'Revogar Consentimento',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: _showRevokeDialog,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Center(
              child: Text(
                'Aguarde, carregando...',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
    );
  }
}

class ConsentHistoryScreen extends StatefulWidget {
  const ConsentHistoryScreen({super.key});

  @override
  State<ConsentHistoryScreen> createState() => _ConsentHistoryScreenState();
}

class _ConsentHistoryScreenState extends State<ConsentHistoryScreen> {
  String? _consentInfo;
  bool _consentAccepted = false;

  @override
  void initState() {
    super.initState();
    _loadConsentInfo();
  }

  Future<void> _loadConsentInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final encryptedInfo = prefs.getString('consent_info');
    final accepted = prefs.getBool('consent_accepted') ?? false;
    setState(() {
      _consentInfo = encryptedInfo;
      _consentAccepted = accepted;
    });
  }

  // Para exibir, simula descriptografia (apenas para exemplo)
  Map<String, dynamic>? _getConsentData() {
    // Não é possível recuperar o original do SHA256, então apenas mostra que está protegido
    if (_consentInfo != null) {
      return {
        'info': 'Dados protegidos por criptografia.',
        'hash': _consentInfo,
      };
    }
    return null;
  }

  Future<void> _revokeConsent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', false);
    await prefs.setBool('consent_accepted', false);
    await prefs.remove('consent_info');
    setState(() {
      _consentAccepted = false;
      _consentInfo = null;
    });
    // Retorna ao onboarding
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const OnboardingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final consentData = _getConsentData();

    return Scaffold(
      backgroundColor: slate,
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
            Icon(Icons.verified_user, color: cyan, size: 60),
            const SizedBox(height: 16),
            Text(
              'Status atual:',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _consentAccepted
                  ? 'Consentimento ACEITO'
                  : 'Consentimento NÃO ACEITO',
              style: TextStyle(
                color: _consentAccepted ? cyan : Colors.redAccent,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 24),
            if (consentData != null) ...[
              Text(
                consentData['info'],
                style: const TextStyle(color: Colors.white70),
              ),
              Text(
                'Hash: ${consentData['hash']}',
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ] else ...[
              const Text(
                'Nenhum consentimento registrado.',
                style: TextStyle(color: Colors.white70),
              ),
            ],
            const SizedBox(height: 32),
            if (_consentAccepted)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: purple,
                    minimumSize: const Size(180, 48),
                  ),
                  icon: const Icon(Icons.cancel, color: Colors.white),
                  label: const Text(
                    'Revogar Consentimento',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: slate,
                        title: Text('Revogar Consentimento', style: TextStyle(color: purple)),
                        content: const Text(
                          'Tem certeza que deseja revogar o consentimento? Você será redirecionado para o início do app.',
                          style: TextStyle(color: Colors.white),
                        ),
                        actions: [
                          TextButton(
                            child: const Text('Cancelar', style: TextStyle(color: cyan)),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          TextButton(
                            child: const Text('Revogar', style: TextStyle(color: purple)),
                            onPressed: () {
                              Navigator.of(context).pop();
                              _revokeConsent();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class Event {
  String nome;
  DateTime horarioInicio;
  DateTime horarioFim;
  Duration duracao;
  List<String> checklist;
  int quantidadePessoas;

  Event({
    required this.nome,
    required this.horarioInicio,
    required this.horarioFim,
    required this.duracao,
    required this.checklist,
    required this.quantidadePessoas,
  });

  Map<String, dynamic> toJson() => {
    'nome': nome,
    'horarioInicio': horarioInicio.toIso8601String(),
    'horarioFim': horarioFim.toIso8601String(),
    'duracao': duracao.inMinutes,
    'checklist': checklist,
    'quantidadePessoas': quantidadePessoas,
  };

  static Event fromJson(Map<String, dynamic> json) => Event(
    nome: json['nome'],
    horarioInicio: DateTime.parse(json['horarioInicio']),
    horarioFim: DateTime.parse(json['horarioFim']),
    duracao: Duration(minutes: json['duracao']),
    checklist: List<String>.from(json['checklist']),
    quantidadePessoas: json['quantidadePessoas'],
  );
}

class EventCrudScreen extends StatefulWidget {
  const EventCrudScreen({super.key});

  @override
  State<EventCrudScreen> createState() => _EventCrudScreenState();
}

class _EventCrudScreenState extends State<EventCrudScreen> {
  List<Event> _events = [];
  final _formKey = GlobalKey<FormState>();
  String _nome = '';
  DateTime _inicio = DateTime.now();
  DateTime _fim = DateTime.now().add(const Duration(hours: 1));
  int _duracao = 60;
  List<String> _checklist = [];
  int _quantidadePessoas = 1;
  final _checklistController = TextEditingController();

  int? _editingIndex;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('events') ?? [];
    setState(() {
      _events = list.map((e) => Event.fromJson(jsonDecode(e))).toList();
    });
  }

  Future<void> _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _events.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('events', list);
  }

  void _addOrUpdateEvent() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      final event = Event(
        nome: _nome,
        horarioInicio: _inicio,
        horarioFim: _fim,
        duracao: Duration(minutes: _duracao),
        checklist: List<String>.from(_checklist),
        quantidadePessoas: _quantidadePessoas,
      );
      setState(() {
        if (_editingIndex != null) {
          _events[_editingIndex!] = event;
        } else {
          _events.add(event);
        }
        _editingIndex = null;
        _checklist = [];
        _checklistController.clear();
      });
      await _saveEvents();
    }
  }

  void _editEvent(int index) {
    final event = _events[index];
    setState(() {
      _editingIndex = index;
      _nome = event.nome;
      _inicio = event.horarioInicio;
      _fim = event.horarioFim;
      _duracao = event.duracao.inMinutes;
      _checklist = List<String>.from(event.checklist);
      _quantidadePessoas = event.quantidadePessoas;
    });
  }

  void _deleteEvent(int index) async {
    setState(() {
      _events.removeAt(index);
    });
    await _saveEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: slate,
      appBar: AppBar(
        backgroundColor: purple,
        title: const Text('Eventos Gamer'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Card(
                color: Colors.white10,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: _nome,
                        decoration: const InputDecoration(
                          labelText: 'Nome do evento',
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                        style: const TextStyle(color: Colors.white),
                        onSaved: (val) => _nome = val ?? '',
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Informe o nome' : null,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Quantidade de pessoas',
                                labelStyle: TextStyle(color: Colors.white),
                              ),
                              style: const TextStyle(color: Colors.white),
                              keyboardType: TextInputType.number,
                              initialValue: _quantidadePessoas.toString(),
                              onSaved: (val) => _quantidadePessoas =
                                  int.tryParse(val ?? '1') ?? 1,
                              validator: (val) {
                                final v = int.tryParse(val ?? '');
                                if (v == null || v < 1) {
                                  return 'Informe um número válido';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Duração (min)',
                                labelStyle: TextStyle(color: Colors.white),
                              ),
                              style: const TextStyle(color: Colors.white),
                              keyboardType: TextInputType.number,
                              initialValue: _duracao.toString(),
                              onSaved: (val) =>
                                  _duracao = int.tryParse(val ?? '60') ?? 60,
                              validator: (val) {
                                final v = int.tryParse(val ?? '');
                                if (v == null || v < 1) {
                                  return 'Informe a duração';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Início (dd/MM/yyyy HH:mm)',
                                labelStyle: TextStyle(color: Colors.white),
                              ),
                              style: const TextStyle(color: Colors.white),
                              initialValue:
                                  DateFormat('dd/MM/yyyy HH:mm').format(_inicio),
                              onSaved: (val) {
                                try {
                                  _inicio = DateFormat('dd/MM/yyyy HH:mm')
                                      .parse(val ?? '');
                                } catch (_) {}
                              },
                              validator: (val) {
                                try {
                                  DateFormat('dd/MM/yyyy HH:mm').parse(val ?? '');
                                  return null;
                                } catch (_) {
                                  return 'Data inválida';
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Fim (dd/MM/yyyy HH:mm)',
                                labelStyle: TextStyle(color: Colors.white),
                              ),
                              style: const TextStyle(color: Colors.white),
                              initialValue:
                                  DateFormat('dd/MM/yyyy HH:mm').format(_fim),
                              onSaved: (val) {
                                try {
                                  _fim = DateFormat('dd/MM/yyyy HH:mm')
                                      .parse(val ?? '');
                                } catch (_) {}
                              },
                              validator: (val) {
                                try {
                                  DateFormat('dd/MM/yyyy HH:mm').parse(val ?? '');
                                  return null;
                                } catch (_) {
                                  return 'Data inválida';
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _checklistController,
                              decoration: const InputDecoration(
                                labelText: 'Item do checklist',
                                labelStyle: TextStyle(color: Colors.white),
                              ),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add, color: cyan),
                            onPressed: () {
                              final item = _checklistController.text.trim();
                              if (item.isNotEmpty) {
                                setState(() {
                                  _checklist.add(item);
                                  _checklistController.clear();
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      Wrap(
                        spacing: 8,
                        children: _checklist
                            .map((item) => Chip(
                                  label: Text(item),
                                  backgroundColor: purple.withOpacity(0.7),
                                  labelStyle: const TextStyle(color: Colors.white),
                                  deleteIcon: const Icon(Icons.close, color: Colors.white),
                                  onDeleted: () {
                                    setState(() {
                                      _checklist.remove(item);
                                    });
                                  },
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: purple,
                            minimumSize: const Size(180, 48),
                          ),
                          onPressed: _addOrUpdateEvent,
                          child: Text(_editingIndex == null ? 'Adicionar Evento' : 'Salvar Alterações'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _events.length,
              itemBuilder: (context, index) {
                final event = _events[index];
                return Card(
                  color: Colors.white10,
                  child: ListTile(
                    title: Text(
                      event.nome,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Início: ${DateFormat('dd/MM/yyyy HH:mm').format(event.horarioInicio)}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        Text(
                          'Fim: ${DateFormat('dd/MM/yyyy HH:mm').format(event.horarioFim)}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        Text(
                          'Duração: ${event.duracao.inMinutes} min',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        Text(
                          'Pessoas: ${event.quantidadePessoas}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        Text(
                          'Checklist: ${event.checklist.join(", ")}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: cyan),
                          onPressed: () => _editEvent(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => _deleteEvent(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
