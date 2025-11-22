import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme.dart';
import 'pages/welcome_ob_page.dart';
import 'pages/how_it_works_ob_page.dart';
import 'pages/ready_ob_page.dart';
import 'pages/marketing_consent_page.dart';
import 'pages/go_to_access_page_ob_page.dart';
import '../home/presentation/pages/home_page.dart';
import 'widgets/dots_indicator.dart';

class OnboardingPage extends StatefulWidget {
  static const routeName = '/onboarding';
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int _currentPage = 0;

  static const int idxReady = 2;
  static const int idxMarketing = 3;
  static const int idxGoToAccess = 4;

  final List<int> dotPages = [0, 1, idxReady];

  final Set<int> pagesWithInternalAdvance = {idxGoToAccess};

  void _goTo(int index) => setState(() => _currentPage = index);
  void _next() {
    if (_currentPage < idxGoToAccess) setState(() => _currentPage++);
  }

  void _skipToMarketing() => _goTo(idxMarketing);

  @override
  Widget build(BuildContext context) {
    final pages = [
      const WelcomeObPage(),
      const HowItWorksObPage(),
      ReadyObPage(onNext: () {
        _goTo(idxMarketing);
      }),
      MarketingConsentPage(onSaved: () {
        _goTo(idxGoToAccess);
      }),
      GoToAcessObPage(onAllAccepted: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('onboarding_done', true);
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed(MyHomePage.routeName);
      }),
    ];

    final showDots = dotPages.contains(_currentPage);
    final dotsCount = dotPages.length;
    final activeDotIndex = showDots ? dotPages.indexOf(_currentPage) : 0;
    final showSkip = _currentPage <= 1;

    return Scaffold(
      backgroundColor: slate,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: pages[_currentPage]),
            if (showSkip)
              Positioned(
                top: 8,
                right: 8,
                child: TextButton(
                  onPressed: _skipToMarketing,
                  style: TextButton.styleFrom(foregroundColor: cyan),
                  child: const Text('Pular'),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: showDots
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DotsIndicator(count: dotsCount, activeIndex: activeDotIndex),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (_currentPage > 0 && _currentPage != idxReady)
                          ElevatedButton(
                            onPressed: _currentPage > 0 ? _goBack : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: slate,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(100, 44),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            ),
                            child: const Text('Voltar'),
                          )
                        else
                          const SizedBox(width: 100),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: pagesWithInternalAdvance.contains(_currentPage) ? null : _next,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: purple,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(140, 44),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          ),
                          child: const Text('Avançar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  void _goBack() {
    if (_currentPage == idxReady) return;
    if (_currentPage > 0) setState(() => _currentPage--);
  }
}
