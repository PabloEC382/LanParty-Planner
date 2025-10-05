import 'package:flutter/material.dart';

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
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: purple,
        title: const Text('Gamer Event Platform'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Exibe a logo personalizada
            Image.asset(
              'PNGs/logoIA.png',
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 16),
            Text(
              'Mini-evento de Sábado',
              style: Theme.of(context).textTheme.headlineMedium,
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
                    checklistItem('Montar setup', true),
                    checklistItem('Comprar snacks', false),
                    checklistItem('Testar conexão', false),
                    checklistItem('Definir jogos', true),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget checklistItem(String text, bool checked) {
    return Row(
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
    );
  }
}
