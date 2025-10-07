import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';

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

// --- TELA DE MARKETING ---
class MarketingConsentPage extends StatefulWidget {
  final VoidCallback onContinue;
  const MarketingConsentPage({super.key, required this.onContinue});

  @override
  State<MarketingConsentPage> createState() => _MarketingConsentPageState();
}

class _MarketingConsentPageState extends State<MarketingConsentPage> {
  bool _marketingConsent = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: slate,
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mark_email_read, color: cyan, size: 80),
                const SizedBox(height: 24),
                Text(
                  'Receber material de marketing',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'Gostaria de receber novidades, promoções e materiais de marketing sobre eventos gamers?',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),
                SwitchListTile(
                  value: _marketingConsent,
                  onChanged: (val) {
                    setState(() {
                      _marketingConsent = val;
                    });
                  },
                  title: const Text(
                    'Receber material de marketing',
                    style: TextStyle(color: Colors.white),
                  ),
                  activeColor: purple,
                  inactiveThumbColor: Colors.white24,
                  inactiveTrackColor: Colors.white10,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: purple,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(200, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: widget.onContinue,
                  child: const Text('Salvar Consentimento'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- TELA DE CONSENTIMENTO (PRONTO PARA COMEÇAR) ---
class ConsentimentoResumoPage extends StatelessWidget {
  final VoidCallback onLerPolitica;
  final VoidCallback onLerTermos;
  final VoidCallback onAvancar;
  final bool politicaLida;
  final bool termosLidos;

  const ConsentimentoResumoPage({
    super.key,
    required this.onLerPolitica,
    required this.onLerTermos,
    required this.onAvancar,
    required this.politicaLida,
    required this.termosLidos,
  });

  @override
  Widget build(BuildContext context) {
    final podeAvancar = politicaLida && termosLidos;
    return SafeArea(
      child: Scaffold(
        backgroundColor: slate,
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.verified_user, color: cyan, size: 80),
                const SizedBox(height: 24),
                Text(
                  'Tudo pronto para Começar',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'Leia e aceite os termos para garantir sua segurança e privacidade.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),
                ListTile(
                  leading: Icon(
                    politicaLida ? Icons.check_circle : Icons.cancel,
                    color: politicaLida ? cyan : Colors.redAccent,
                  ),
                  title: const Text('Política de Privacidade', style: TextStyle(color: Colors.white)),
                  trailing: TextButton(
                    onPressed: onLerPolitica,
                    child: const Text('Ler', style: TextStyle(color: cyan)),
                  ),
                ),
                ListTile(
                  leading: Icon(
                    termosLidos ? Icons.check_circle : Icons.cancel,
                    color: termosLidos ? cyan : Colors.redAccent,
                  ),
                  title: const Text('Termos de Uso', style: TextStyle(color: Colors.white)),
                  trailing: TextButton(
                    onPressed: onLerTermos,
                    child: const Text('Ler', style: TextStyle(color: cyan)),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: podeAvancar ? purple : Colors.grey,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(220, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: podeAvancar ? onAvancar : null,
                  child: const Text('Avançar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- TELA DE LEITURA DE POLÍTICA/TERMOS ---
class LeituraMdPage extends StatefulWidget {
  final String titulo;
  final String assetPath;
  final VoidCallback onLeuTudo;

  const LeituraMdPage({
    super.key,
    required this.titulo,
    required this.assetPath,
    required this.onLeuTudo,
  });

  @override
  State<LeituraMdPage> createState() => _LeituraMdPageState();
}

class _LeituraMdPageState extends State<LeituraMdPage> {
  String _conteudo = '';
  bool _leuTudo = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _carregarMd();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _carregarMd() async {
    final texto = await rootBundle.loadString(widget.assetPath);
    setState(() {
      _conteudo = texto;
    });
  }

  void _onScroll() {
    if (!_leuTudo &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 10) {
      setState(() {
        _leuTudo = true;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: slate,
      appBar: AppBar(
        backgroundColor: purple,
        title: Text(widget.titulo),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: _conteudo.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(24),
                    child: SelectableText(
                      _conteudo,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FilledButton.icon(
                onPressed: _leuTudo ? widget.onLeuTudo : null,
                icon: const Icon(Icons.check),
                label: const Text('Concordo com os termos'),
                style: FilledButton.styleFrom(
                  backgroundColor: _leuTudo ? purple : slate,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(220, 48),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- INTEGRAÇÃO NO ONBOARDING ---
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentPage = 0;
  bool _politicaLida = false;
  bool _termosLidos = false;

  void _irParaPolitica() async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => LeituraMdPage(
        titulo: 'Política de Privacidade',
        assetPath: 'privacidade.md',
        onLeuTudo: () {
          setState(() => _politicaLida = true);
          Navigator.of(context).pop();
        },
      ),
    ));
  }

  void _irParaTermos() async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => LeituraMdPage(
        titulo: 'Termos de Uso',
        assetPath: 'termos.md',
        onLeuTudo: () {
          setState(() => _termosLidos = true);
          Navigator.of(context).pop();
        },
      ),
    ));
  }

  void _avancarConsentimento() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    await prefs.setBool('consent_accepted', true);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MyHomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      Center(
        child: SingleChildScrollView(
          child: Column(
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
        ),
      ),
      Center(
        child: SingleChildScrollView(
          child: Column(
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
        ),
      ),
      Center(
        child: SingleChildScrollView(
          child: Column(
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
        ),
      ),
      MarketingConsentPage(
        onContinue: () {
          setState(() => _currentPage = 4);
        },
      ),
      ConsentimentoResumoPage(
        onLerPolitica: _irParaPolitica,
        onLerTermos: _irParaTermos,
        onAvancar: _avancarConsentimento,
        politicaLida: _politicaLida,
        termosLidos: _termosLidos,
      ),
    ];

    return Scaffold(
      backgroundColor: slate,
      body: pages[_currentPage],
      bottomNavigationBar: _currentPage < 3
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: slate,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(100, 40),
                      ),
                      onPressed: () {
                        setState(() {
                          _currentPage--;
                        });
                      },
                      child: const Text('Voltar'),
                    ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: purple,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(100, 40),
                    ),
                    onPressed: () {
                      setState(() {
                        _currentPage++;
                      });
                    },
                    child: const Text('Avançar'),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}

class ConsentPageFS extends StatefulWidget {
  final VoidCallback onConsentAccepted;
  const ConsentPageFS({super.key, required this.onConsentAccepted});

  @override
  State<ConsentPageFS> createState() => _ConsentPageFSState();
}

class _ConsentPageFSState extends State<ConsentPageFS> {
  final ScrollController _scrollController = ScrollController();
  bool _reachedEnd = false;

  final String _policyContent = '''
**Termos de Uso e Política de Privacidade**

Ao utilizar este aplicativo, você concorda com os seguintes termos:

- Seus dados serão utilizados apenas para funcionamento do app.
- Nenhum dado pessoal será compartilhado com terceiros sem sua autorização.
- Você pode revogar o consentimento a qualquer momento nas configurações.

Leia atentamente todos os termos antes de aceitar.
  ''';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_reachedEnd &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent) {
      setState(() {
        _reachedEnd = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.verified_user, color: cyan, size: 80),
                const SizedBox(height: 24),
                Text(
                  'Consentimento',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  _policyContent,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    _reachedEnd
                        ? 'Você leu até o final. Agora pode aceitar os termos.'
                        : 'Role até o final para aceitar os termos.',
                    style: TextStyle(
                      color: _reachedEnd ? Colors.greenAccent : Colors.white70,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: FilledButton.icon(
              onPressed: _reachedEnd ? widget.onConsentAccepted : null,
              icon: const Icon(Icons.check),
              label: const Text('Concordo com os termos'),
              style: FilledButton.styleFrom(
                backgroundColor: _reachedEnd ? purple : slate,
                foregroundColor: Colors.white,
                minimumSize: const Size(220, 48),
              ),
            ),
          ),
        ),
      ],
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
  List<Event> _events = [];

  @override
  void initState() {
    super.initState();
    _checkAccess();
    _loadEvents();
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

  Future<void> _loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('events') ?? [];
    setState(() {
      _events = list.map((e) => Event.fromJson(jsonDecode(e))).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
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
              label: 'Eventos',
              child: IconButton(
                icon: Icon(Icons.event, color: cyan),
                tooltip: 'Eventos',
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const EventCrudScreen()),
                  );
                  await _loadEvents(); // Atualiza eventos ao voltar do CRUD
                },
              ),
            ),
          ),
        ],
      ),
      body: _canAccess
          ? Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
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
                      'Eventos cadastrados',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    if (_events.isEmpty)
                      Text(
                        'Nenhum evento cadastrado.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ..._events.map((event) => Card(
                          color: slate,
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.nome,
                                  style: TextStyle(
                                    color: cyan,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                const SizedBox(height: 8),
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
                                const SizedBox(height: 8),
                                Center(
                                  child: Text(
                                    'Checklist:',
                                    style: TextStyle(
                                      color: cyan,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (event.checklist.isNotEmpty)
                                  Column(
                                    children: event.checklist
                                        .map((item) => Center(
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.check_circle, color: purple, size: 20),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    item,
                                                    style: const TextStyle(color: Colors.white),
                                                  ),
                                                ],
                                              ),
                                            ))
                                        .toList(),
                                  ),
                              ],
                            ),
                          ),
                        )),
                  ],
                ),
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

  Map<String, dynamic>? _getConsentData() {
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
      Navigator.of(context).pop(); // Fecha o CRUD após salvar
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
                        decoration: InputDecoration(
                          labelText: 'Nome do evento',
                          labelStyle: const TextStyle(color: Colors.white),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: cyan),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: purple),
                          ),
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
                              decoration: InputDecoration(
                                labelText: 'Quantidade de pessoas',
                                labelStyle: const TextStyle(color: Colors.white),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: cyan),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: purple),
                                ),
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
                              decoration: InputDecoration(
                                labelText: 'Duração (min)',
                                labelStyle: const TextStyle(color: Colors.white),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: cyan),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: purple),
                                ),
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
                              decoration: InputDecoration(
                                labelText: 'Início (dd/MM/yyyy HH:mm)',
                                labelStyle: const TextStyle(color: Colors.white),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: cyan),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: purple),
                                ),
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
                              decoration: InputDecoration(
                                labelText: 'Fim (dd/MM/yyyy HH:mm)',
                                labelStyle: const TextStyle(color: Colors.white),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: cyan),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: purple),
                                ),
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
                              decoration: InputDecoration(
                                labelText: 'Item do checklist',
                                labelStyle: const TextStyle(color: Colors.white),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: cyan),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: purple),
                                ),
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
                            foregroundColor: Colors.white,
                            minimumSize: const Size(180, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
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
                          icon: Icon(Icons.edit, color: cyan),
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
