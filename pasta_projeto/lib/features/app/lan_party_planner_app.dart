import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../splashscreen/splashscreen_page.dart';
import '../onboarding/onboarding_page.dart';
import '../home/presentation/pages/home_page.dart';
import '../home/presentation/pages/profile_page.dart';

class LanPartyPlannerApp extends StatelessWidget {
  const LanPartyPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gamer Event Platform',
      theme: appTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: SplashscreenPage.routeName,
      routes: {
        SplashscreenPage.routeName: (_) => const SplashscreenPage(),
        OnboardingPage.routeName: (_) => const OnboardingPage(),
        MyHomePage.routeName: (_) => const MyHomePage(),
        ProfilePage.routeName: (_) => const ProfilePage(),
      },
    );
  }
}