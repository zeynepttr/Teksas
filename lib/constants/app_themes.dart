import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppThemes {
  static ThemeData get lightTheme {
    // Start with a light theme base
    final baseTheme = ThemeData.light(useMaterial3: true);

    // Apply Google Fonts Outfit which has similar modern, rounded geometric shapes to DINPro
    final textTheme = GoogleFonts.outfitTextTheme(baseTheme.textTheme).copyWith(
      displayLarge: const TextStyle(
        fontFamily: 'DINPro',
        fontWeight: FontWeight.w700, // Bold
        color: AppColors.textPrimary,
      ),
      displayMedium: const TextStyle(
        fontFamily: 'DINPro',
        fontWeight: FontWeight.w500, // Medium
        color: AppColors.textPrimary,
      ),
      titleLarge: const TextStyle(
        fontFamily: 'DINPro',
        fontWeight: FontWeight.w700,
        fontSize: 22.0,
        color: AppColors.textPrimary,
      ),
      titleMedium: const TextStyle(
        fontFamily: 'DINPro',
        fontWeight: FontWeight.w500,
        fontSize: 16.0,
        color: AppColors.textSecondary,
      ),
      bodyLarge: const TextStyle(
        fontFamily: 'DINPro',
        fontWeight: FontWeight.w500,
        fontSize: 16.0,
        color: AppColors.textPrimary,
      ),
      bodyMedium: const TextStyle(
        fontFamily: 'DINPro',
        fontWeight: FontWeight.w500,
        fontSize: 14.0,
        color: AppColors.textSecondary,
      ),
    );

    return baseTheme.copyWith(
      colorScheme: const ColorScheme.light(
        primary: AppColors.accent,
        secondary: AppColors.oliveGreen,
        background: AppColors.background,
        surface: AppColors.surface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme,
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: TextStyle(fontSize: 11),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Drawer Theme
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.surface,
        elevation: 16,
      ),

      // Input Decoration Theme (Text fields)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.surfaceLight, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.surfaceLight, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 2.0),
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.surfaceLight, width: 1),
        ),
      ),

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'DINPro',
          fontWeight: FontWeight.w700,
          fontSize: 20,
          color: AppColors.textPrimary,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
    );
  }
}
