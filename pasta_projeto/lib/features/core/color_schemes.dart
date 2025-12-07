import 'package:flutter/material.dart';

/// ==================== CORES BASE ====================
/// Cores principais utilizadas em ambos os temas

const Color purple = Color(0xFF7C3AED);
const Color cyan = Color(0xFF06B6D4);
const Color slate = Color(0xFF0F172A);

// Variações do roxo para uso em containers
const Color purpleContainer = Color(0xFFEDE9FE);
const Color onPurpleContainer = Color(0xFF3F0F7F);

// Variações do cyan para uso em containers
const Color cyanContainer = Color(0xFFCFFAFE);
const Color onCyanContainer = Color(0xFF003638);

// ==================== PALETA ESCURA ====================
/// ColorScheme para tema escuro
const ColorScheme darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  // Cores primárias (roxo)
  primary: purple,
  onPrimary: Colors.white,
  primaryContainer: Color(0xFF5B21B6),
  onPrimaryContainer: Color(0xFFEDE9FE),
  // Cores secundárias (cyan)
  secondary: cyan,
  onSecondary: Colors.white,
  secondaryContainer: Color(0xFF004D50),
  onSecondaryContainer: Color(0xFFCFFAFE),
  // Cores terciárias
  tertiary: Color(0xFF818CF8),
  onTertiary: Colors.white,
  tertiaryContainer: Color(0xFF312E81),
  onTertiaryContainer: Color(0xFFE0E7FF),
  // Superfícies
  surface: slate,
  onSurface: Colors.white,
  surfaceContainerHighest: Color(0xFF1E293B),
  onSurfaceVariant: Color(0xFFCBD5E1),
  // Erro
  error: Colors.redAccent,
  onError: Colors.white,
  errorContainer: Color(0xFF7F1D1D),
  onErrorContainer: Color(0xFFFEE2E2),
  // Outros
  outline: Color(0xFF64748B),
  outlineVariant: Color(0xFF475569),
  shadow: Colors.black,
  scrim: Colors.black,
  inverseSurface: Color(0xFFF1F5F9),
  onInverseSurface: Color(0xFF0F172A),
  inversePrimary: Color(0xFFA855F7),
  surfaceTint: purple,
);

// ==================== PALETA CLARA ====================
/// ColorScheme para tema claro personalizado
const ColorScheme lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  // Cores primárias (roxo)
  primary: Color(0xFF7C3AED),
  onPrimary: Colors.white,
  primaryContainer: Color(0xFFEDE9FE),
  onPrimaryContainer: Color(0xFF3F0F7F),
  // Cores secundárias (cyan)
  secondary: Color(0xFF0891B2),
  onSecondary: Colors.white,
  secondaryContainer: Color(0xFFCFFAFE),
  onSecondaryContainer: Color(0xFF003638),
  // Cores terciárias
  tertiary: Color(0xFF6366F1),
  onTertiary: Colors.white,
  tertiaryContainer: Color(0xFFE0E7FF),
  onTertiaryContainer: Color(0xFF1E1B4B),
  // Superfícies
  surface: Color(0xFFFAFAFA),
  onSurface: Color(0xFF1F2937),
  surfaceContainerHighest: Color(0xFFE5E7EB),
  onSurfaceVariant: Color(0xFF4B5563),
  // Erro
  error: Color(0xFFDC2626),
  onError: Colors.white,
  errorContainer: Color(0xFFFEE2E2),
  onErrorContainer: Color(0xFF7F1D1D),
  // Outros
  outline: Color(0xFF9CA3AF),
  outlineVariant: Color(0xFFD1D5DB),
  shadow: Color(0xFF000000),
  scrim: Color(0xFF000000),
  inverseSurface: Color(0xFF1F2937),
  onInverseSurface: Color(0xFFFAFAFA),
  inversePrimary: Color(0xFFC4B5FD),
  surfaceTint: Color(0xFF7C3AED),
);
