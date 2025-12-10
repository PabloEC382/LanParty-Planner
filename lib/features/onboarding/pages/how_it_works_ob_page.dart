import 'package:flutter/material.dart';
import '../../core/theme.dart';

class HowItWorksObPage extends StatelessWidget {
  const HowItWorksObPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline, color: cyan, size: 80),
            const SizedBox(height: 24),
            Text('O que é o Gamer Event Platform?', style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text('Crie eventos, marque tarefas e acompanhe o progresso do seu mini-evento gamer com checklist e horários!', style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}