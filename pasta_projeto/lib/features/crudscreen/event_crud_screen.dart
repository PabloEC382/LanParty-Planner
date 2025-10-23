import 'package:flutter/material.dart';
import '../core/theme.dart';

class EventCrudScreen extends StatelessWidget {
  const EventCrudScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: slate,
      appBar: AppBar(
        backgroundColor: purple,
        title: const Text('Gerenciar Eventos'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.event, size: 56, color: Colors.white70),
            SizedBox(height: 16),
            Text('CRUD de eventos (em desenvolvimento)', style: TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}