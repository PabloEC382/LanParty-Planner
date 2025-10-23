import 'package:flutter/material.dart';
import '../core/theme.dart';

class PolicyListTile extends StatelessWidget {
  final String title;
  final VoidCallback onRead;
  final bool read;
  const PolicyListTile({super.key, required this.title, required this.onRead, this.read = false});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(read ? Icons.check_circle : Icons.cancel, color: read ? cyan : Colors.redAccent),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: TextButton(onPressed: onRead, child: const Text('Ler', style: TextStyle(color: cyan))),
    );
  }
}