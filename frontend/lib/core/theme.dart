import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const bg = Color(0xFF0A1424);
  static const sidebar = Color(0xFF0E2145);
  static const card = Color(0xFF0F1C31);
  static const border = Color(0xFF1E2D45);
  static const textPrimary = Color(0xFFF1F5F9);
  static const textMuted = Color(0xFF8FA0BA);
  static const accent = Color(0xFF2F7DE1);
  static const pagantes = Color(0xFF4A8BDF);
  static const naoPagantes = Color(0xFFF5A33A);
  static const viagens = Color(0xFFEF4444);
  static const teal = Color(0xFF19C3B1);
}

ThemeData buildDarkTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: base.colorScheme.copyWith(primary: AppColors.accent),
    textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    ),
    dividerColor: AppColors.border,
  );
}

TextStyle monoStyle({double size = 14, FontWeight weight = FontWeight.w700, Color? color}) =>
    GoogleFonts.jetBrainsMono(
      fontSize: size,
      fontWeight: weight,
      color: color ?? AppColors.textPrimary,
    );
