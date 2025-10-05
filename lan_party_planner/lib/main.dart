import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

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

  Future<void> _saveOnboardingData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    await prefs.setBool('consent_accepted', _consentAccepted);
  }

  void _nextPage() {
    setState(() {
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
          Image.asset('PNGs/logoIA.png', width: 120, height: 120),
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
      Column(
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
            child: Text(
              'Para usar o app, você precisa aceitar os termos de uso e política de privacidade.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          CheckboxListTile(
            title: const Text(
              'Eu aceito os termos de uso e política de privacidade.',
              style: TextStyle(color: Colors.white),
            ),
            value: _consentAccepted,
            activeColor: purple,
            onChanged: (val) {
              setState(() {
                _consentAccepted = val ?? false;
              });
            },
          ),
        ],
      ),
    ];

    return Scaffold(
      backgroundColor: slate,
      body: Center(
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
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Voltar
                  if (_currentPage > 0)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: slate,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(100, 40),
                      ),
                      onPressed: _prevPage,
                      child: const Text('Voltar'),
                    )
                  else
                    const SizedBox(width: 100),
                  // Pular
                  if (_currentPage < 3)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cyan,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(100, 40),
                      ),
                      onPressed: _skipToConsent,
                      child: const Text('Pular'),
                    )
                  else
                    const SizedBox(width: 100),
                ],
              ),
              const SizedBox(height: 16),
              // Avançar/Consentir
              if (_currentPage == 0 || _currentPage == 1 || _currentPage == 2)
                ElevatedButton(
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
              if (_currentPage == 3)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: purple,
                    minimumSize: const Size(180, 48),
                  ),
                  onPressed: _consentAccepted ? _finishOnboarding : null,
                  child: const Text(
                    'Consentir',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
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
  final List<bool> _checklistStatus = [true, false, false, true];
  final List<String> _checklistItems = [
    'Montar setup',
    'Comprar snacks',
    'Testar conexão',
    'Definir jogos',
  ];

  Future<void> _revokeConsent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', false);
    await prefs.setBool('consent_accepted', false);
    // Volta para o onboarding
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: purple,
        title: const Text('Gamer Event Platform'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: cyan),
            tooltip: 'Revogar Consentimento',
            onPressed: _showRevokeDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              'PNGs/logoIA.png',
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
                    // Checklist interativo
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
            ElevatedButton.icon(
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
          ],
        ),
      ),
    );
  }

  Widget checklistItem(String text, bool checked, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(
          children: [
            Icon(
              checked ? Icons.check_circle : Icons.radio_button_unchecked,
              color: checked ? purple : Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: Colors.white,
                decoration: checked ? TextDecoration.lineThrough : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
