import 'package:flutter/material.dart';
class WelcomeObPage extends StatelessWidget {
  const WelcomeObPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/PNGs/logoIASemfundo.png', width: 120, height: 120),
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
    );
  }
}