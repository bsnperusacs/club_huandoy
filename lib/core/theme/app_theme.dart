// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'colores.dart';

class AppTheme {

  /// ============================================================
  /// GRADIENT GLOBAL — Verde + Celeste institucional
  /// ============================================================
  static const LinearGradient headerGradient = LinearGradient(
    colors: [
      AppColors.verde,
      AppColors.celeste,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// ============================================================
  /// TEMA PRINCIPAL
  /// ============================================================
  static ThemeData light = ThemeData(
    useMaterial3: true,

    primaryColor: AppColors.verde,
    scaffoldBackgroundColor: Colors.white,

    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.verde,
      primary: AppColors.verde,
      secondary: AppColors.celeste,
    ),

    /// ============================================================
    /// INPUTS — Campos de texto bonitos, globales
    /// ============================================================
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.celeste.withOpacity(0.15),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),

      prefixIconColor: AppColors.verde,

      labelStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        color: AppColors.textoOscuro,
      ),
    ),

    /// ============================================================
    /// BOTONES ELEVATEDBUTTON
    /// ============================================================
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.verde,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      ),
    ),

    /// ============================================================
    /// FLOATING ACTION BUTTON
    /// ============================================================
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.verde,
      foregroundColor: Colors.white,
      shape: StadiumBorder(),
    ),
  );
}
