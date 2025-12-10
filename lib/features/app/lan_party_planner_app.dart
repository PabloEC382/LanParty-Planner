import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/theme_controller.dart';
import '../splashscreen/splashscreen_page.dart';
import '../onboarding/onboarding_page.dart';
import '../home/presentation/pages/home_page.dart';
import '../home/presentation/pages/profile_page.dart';

class LanPartyPlannerApp extends StatelessWidget {
  final ThemeController themeController;

  const LanPartyPlannerApp({
    super.key,
    required this.themeController,
  });

  @override
  Widget build(BuildContext context) {
    // ListenableBuilder reconstrói quando o controller notifica
    return ListenableBuilder(
      listenable: themeController,
      builder: (context, child) {
        return MaterialApp(
          title: 'Gamer Event Platform',
          // Usa o modo do controller em vez de fixo
          themeMode: themeController.mode,
          theme: lightAppTheme,
          darkTheme: darkAppTheme,
          debugShowCheckedModeBanner: false,
          initialRoute: SplashscreenPage.routeName,
          routes: {
            SplashscreenPage.routeName: (_) => const SplashscreenPage(),
            OnboardingPage.routeName: (_) => const OnboardingPage(),
            MyHomePage.routeName: (_) => MyHomePage(themeController: themeController),
            ProfilePage.routeName: (_) => const ProfilePage(),
          },
        );
      },
    );
  }
}