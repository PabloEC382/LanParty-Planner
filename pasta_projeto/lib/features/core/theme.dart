import 'package:flutter/material.dart';
import 'color_schemes.dart';

const Color purple = Color(0xFF7C3AED);
const Color cyan = Color(0xFF06B6D4);
const Color slate = Color(0xFF0F172A);

/// ==================== TEMA ESCURO ====================
final ThemeData darkAppTheme = ThemeData(
  brightness: Brightness.dark,
  useMaterial3: true,
  colorScheme: darkColorScheme,
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
    style: TextButton.styleFrom(foregroundColor: yellow),
  ),
  iconTheme: const IconThemeData(color: Colors.white),
  textTheme: const TextTheme(
    headlineMedium: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
    bodyMedium: TextStyle(color: Colors.white, fontSize: 16),
    labelLarge: TextStyle(color: Colors.white),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFFFBBF24), // Amarelo dourado
    hintStyle: const TextStyle(color: Color(0xFF78350F)),
    labelStyle: const TextStyle(color: Color(0xFF78350F)),
    enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFBBF24))),
    focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFBBF24))),
  ),
);

/// ==================== TEMA CLARO ====================
final ThemeData lightAppTheme = ThemeData(
  brightness: Brightness.light,
  useMaterial3: true,
  colorScheme: lightColorScheme,
  scaffoldBackgroundColor: const Color(0xFFFFFFFF),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF7C3AED),
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF7C3AED),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      minimumSize: const Size(180, 48),
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: const Color(0xFF7C3AED),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      minimumSize: const Size(180, 48),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: const Color(0xFFFBBF24)),
  ),
  iconTheme: const IconThemeData(color: Color(0xFF1F2937)),
  textTheme: const TextTheme(
    headlineMedium: TextStyle(color: Color(0xFF1F2937), fontSize: 24, fontWeight: FontWeight.bold),
    bodyMedium: TextStyle(color: Color(0xFF4B5563), fontSize: 16),
    labelLarge: TextStyle(color: Color(0xFF1F2937)), // Preto em tema claro
  ),
  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: Color(0xFFF3F4F6),
    hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
    labelStyle: TextStyle(color: Color(0xFF6B7280)),
    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFBBF24))),
    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF7C3AED))),
  ),
);

/// Tema padrão (escuro) para compatibilidade com código legado
final ThemeData appTheme = darkAppTheme;