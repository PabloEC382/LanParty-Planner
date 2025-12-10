import 'package:flutter/material.dart';
import '../pages/home_page.dart';

/// Helper para adicionar botão Home nas AppBars
AppBar buildAppBarWithHome(
  BuildContext context, {
  required String title,
  List<Widget>? actions,
  bool centerTitle = true,
  Color backgroundColor = const Color(0xFF7C3AED),
}) {
  return AppBar(
    backgroundColor: backgroundColor,
    title: Text(title),
    centerTitle: centerTitle,
    actions: [
      ...(actions ?? []),
      IconButton(
        icon: const Icon(Icons.home),
        onPressed: () {
          Navigator.of(context).popUntil((route) {
            return route.settings.name == MyHomePage.routeName ||
                route.isFirst;
          });
          if (ModalRoute.of(context)?.settings.name != MyHomePage.routeName) {
            Navigator.of(context).pushNamed(MyHomePage.routeName);
          }
        },
        tooltip: 'Início',
      ),
    ],
  );
}

/// Versão simplificada
AppBar buildSimpleAppBar(
  String title, {
  bool showHomeButton = true,
  BuildContext? context,
  Color backgroundColor = const Color(0xFF7C3AED),
  List<Widget>? actions,
}) {
  return AppBar(
    backgroundColor: backgroundColor,
    title: Text(title),
    centerTitle: true,
    actions: [
      ...(actions ?? []),
      if (showHomeButton && context != null)
        IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            Navigator.of(context).popUntil((route) {
              return route.settings.name == MyHomePage.routeName ||
                  route.isFirst;
            });
            if (ModalRoute.of(context)?.settings.name !=
                MyHomePage.routeName) {
              Navigator.of(context).pushNamed(MyHomePage.routeName);
            }
          },
          tooltip: 'Início',
        ),
    ],
  );
}
