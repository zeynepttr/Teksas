import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color darkGreen = Color(0xFF036A37);      // #036a37 (Koyu Yeşil)
  static const Color oliveGreen = Color(0xFF898C32);     // #898c32 (Zeytin Yeşili)
  static const Color buttonDark = Color(0xFF1FAD4E);     // #1fad4e (Buton Rengi Koyu)
  static const Color buttonLight = Color(0xFFDEF3E5);    // #def3e5 (Buton Rengi Açık)

  // Neutral Theme Colors - PREMIUM LIGHT THEME (Soft, clean, and high-end)
  static const Color background = Color(0xFFF3F7F4);     // Premium light off-white with soft sage tint
  static const Color backgroundEnd = Color(0xFFE5ECE7);  // Warm soft grey-green background gradient end
  static const Color surface = Color(0xFFFFFFFF);        // Pure white for card surfaces
  static const Color surfaceLight = Color(0xFFE5ECE8);   // Soft sage grey for borders, dividers, and inactive fields
  
  // Text Colors
  static const Color textPrimary = Color(0xFF0C1911);    // Deep dark forest green-black for high contrast readability
  static const Color textSecondary = Color(0xFF4C5E53);  // Muted forest grey-green for descriptions/subtitles
  static const Color textMuted = Color(0xFF80988A);      // Soft slate-green for hint text
  
  // Accent & State Colors
  static const Color accent = Color(0xFF036A37);         // Koyu Yeşil as the main active accent
  static const Color error = Color(0xFFD32F2F);          // Premium warning/error red
  static const Color warning = Color(0xFFF57C00);        // Premium warning orange
  static const Color success = Color(0xFF1FAD4E);        // Green success

  // Gradient definitions for premium looks
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [darkGreen, Color(0xFF0C8A4B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient buttonGradient = LinearGradient(
    colors: [buttonDark, Color(0xFF2EE668)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [background, backgroundEnd],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [surface, Color(0xFFF8FAF8)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
