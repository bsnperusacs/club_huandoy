import 'package:flutter/material.dart';
import 'colores.dart';

class AppTheme {
  /// GRADIENTE INSTITUCIONAL
  static const LinearGradient headerGradient = LinearGradient(
    colors: [
      AppColors.verde,
      AppColors.celeste,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// TEMA PRINCIPAL
  static ThemeData light = ThemeData(
    useMaterial3: true,

    scaffoldBackgroundColor: AppColors.grisSuave,
    primaryColor: AppColors.verde,

    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.verde,
      primary: AppColors.verde,
      secondary: AppColors.celeste,
    ),

    /// TEXTOS GLOBALES
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontWeight: FontWeight.bold,
        color: AppColors.textoOscuro,
      ),
      titleMedium: TextStyle(
        fontWeight: FontWeight.w600,
        color: AppColors.textoOscuro,
      ),
      bodyMedium: TextStyle(
        color: AppColors.textoOscuro,
      ),
      bodySmall: TextStyle(
        color: AppColors.textoOscuro,
      ),
    ),

    /// INPUTS
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

            cardTheme: CardThemeData(
              color: AppColors.blanco,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),


    /// BOTONES
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.verde,
        foregroundColor: AppColors.blanco,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    ),

    /// APPBAR
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.verde,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
    ),

    /// FAB
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.verde,
      foregroundColor: Colors.white,
    ),
  );
}
