import 'package:flutter/material.dart';

const Color purple = Color(0xFF7C3AED);
const Color cyan = Color(0xFF06B6D4);
const Color slate = Color(0xFF0F172A);

final ThemeData appTheme = ThemeData(
  brightness: Brightness.dark,
  useMaterial3: true,
  colorScheme: ColorScheme.dark(
    primary: purple,
    onPrimary: Colors.white,
    secondary: cyan,
    onSecondary: Colors.white,
    surface: slate,
    onSurface: Colors.white,
    error: Colors.redAccent,
    onError: Colors.white,
  ),
  scaffoldBackgroundColor: slate,
  appBarTheme: const AppBarTheme(
    backgroundColor: purple,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: purple,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      minimumSize: const Size(180, 48),
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: purple,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      minimumSize: const Size(180, 48),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: cyan),
  ),
  iconTheme: const IconThemeData(color: Colors.white),
  textTheme: const TextTheme(
    headlineMedium: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
    bodyMedium: TextStyle(color: Colors.white, fontSize: 16),
    labelLarge: TextStyle(color: Colors.white),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: slate.withOpacity(0.12),
    hintStyle: const TextStyle(color: Colors.white54),
    labelStyle: const TextStyle(color: Colors.white70),
    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: cyan)),
    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: purple)),
  ),
);