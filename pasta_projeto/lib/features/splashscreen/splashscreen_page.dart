import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme.dart';
import '../onboarding/onboarding_page.dart';
import '../home/presentation/pages/home_page.dart';

class SplashscreenPage extends StatefulWidget {
  static const routeName = '/';
  const SplashscreenPage({super.key});

  @override
  State<SplashscreenPage> createState() => _SplashscreenPageState();
}

class _SplashscreenPageState extends State<SplashscreenPage> {
  @override
  void initState() {
    super.initState();
    _checkFirstRun();
  }

  Future<void> _checkFirstRun() async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('onboarding_done') ?? false;
    Timer(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      if (onboardingDone) {
        Navigator.of(context).pushReplacementNamed(MyHomePage.routeName);
      } else {
        Navigator.of(context).pushReplacementNamed(OnboardingPage.routeName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final logoSize = MediaQuery.of(context).size.width * 0.32;
    final titleStyle = TextStyle(
      color: purple,
      fontWeight: FontWeight.bold,
      fontSize: MediaQuery.of(context).size.width > 360 ? 20 : 18,
      letterSpacing: 1.6,
    );

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // logo centralizado
              SizedBox(
                width: logoSize,
                height: logoSize,
                child: Image.asset(
                  'assets/PNGs/logoIASemfundo.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'GAMER EVENT PLATFORM',
                style: titleStyle,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}