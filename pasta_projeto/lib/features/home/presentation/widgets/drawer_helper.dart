import 'package:flutter/material.dart';
import '../widgets/tutorial_popup.dart';

/// Widget auxiliar que constrói um Drawer com o botão de Tutorial
Widget buildTutorialDrawer(BuildContext context, {
  required List<Widget> children,
}) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        ...children,
        const Divider(),
        ListTile(
          leading: const Icon(Icons.help_outline),
          title: const Text('📚 Tutorial'),
          onTap: () {
            Navigator.pop(context); // Fecha o drawer
            TutorialPopup.show(context);
          },
        ),
      ],
    ),
  );
}
