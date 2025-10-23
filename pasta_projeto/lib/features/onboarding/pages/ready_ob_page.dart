import 'package:flutter/material.dart';
import '../../core/theme.dart';

class ReadyObPage extends StatelessWidget {
  final VoidCallback onNext;
  const ReadyObPage({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.celebration, color: cyan, size: 88),
              const SizedBox(height: 20),
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
    );
  }
}
