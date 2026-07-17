import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color darkGreen = Color(0xFF036A37);      // #036a37
  static const Color oliveGreen = Color(0xFF898C32);     // #898c32
  static const Color buttonDark = Color(0xFF1FAD4E);     // #1fad4e
  static const Color buttonLight = Color(0xFFDEF3E5);    // #def3e5

  // Neutral Theme Colors (Dark Theme Focus for premium look, with clean light accents)
  static const Color background = Color(0xFF0B140F);     // Very deep dark green-grey background
  static const Color surface = Color(0xFF122218);        // Card background
  static const Color surfaceLight = Color(0xFF1A2E22);   // Slightly lighter card/surface
  
  // Text Colors
  static const Color textPrimary = Color(0xFFF3F6F4);    // Off-white for high readability
  static const Color textSecondary = Color(0xFFA0B3A6);  // Muted light sage-grey
  static const Color textMuted = Color(0xFF6B8273);      // Darker muted green-grey
  
  // Accent & State Colors
  static const Color accent = Color(0xFF2AE06E);         // Electric lime green
  static const Color error = Color(0xFFCF6679);          // Muted red for errors
  static const Color warning = Color(0xFFF3B43F);        // Muted yellow
  static const Color success = Color(0xFF1FAD4E);        // Green success

  // Gradient definitions for premium glassmorphic or glowing looks
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

  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [surface, Color(0xFF0F1E15)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
