import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color background = Color(0xFF09090B); // Deepest Black
  static const Color surface = Color(0xFF131316);    // Dark Void
  static const Color accent = Color(0xFF00FFCC);     // Cyber Neon Cyan
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA1A1AA);
  static const Color alert = Color(0xFFFF0055);      // Neon Pink

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: accent,
        surface: surface,
        onSurface: textPrimary,
        error: alert,
      ),
      textTheme: GoogleFonts.rajdhaniTextTheme( // High-energy cyber/gamer font
        const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32, 
            fontWeight: FontWeight.w700, 
            color: textPrimary,
            letterSpacing: 1.5,
          ),
          displayMedium: TextStyle(
            fontSize: 24, 
            fontWeight: FontWeight.w700, 
            color: textPrimary,
            letterSpacing: 1.0,
          ),
          titleMedium: TextStyle(
            fontSize: 16, 
            fontWeight: FontWeight.w700, 
            color: textPrimary, 
            letterSpacing: 2.0,
          ),
          bodyLarge: TextStyle(
            fontSize: 16, 
            fontWeight: FontWeight.w600,
            color: textPrimary, 
            height: 1.5,
          ),
          bodyMedium: TextStyle(
            fontSize: 14, 
            fontWeight: FontWeight.w500,
            color: textSecondary, 
            height: 1.4,
          ),
        ),
      ),
    );
  }

  static BoxDecoration glass({
    double blur = 10, // Sharper for gaming theme
    double opacity = 0.1, // slightly more visible
    BorderRadius? radius,
    Color? color,
  }) {
    return BoxDecoration(
      color: (color ?? background).withOpacity(opacity),
      borderRadius: radius ?? BorderRadius.circular(12), // Sharper corners
      border: Border.all(
        color: accent.withOpacity(0.5), // Electric neon border
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: accent.withOpacity(0.15),
          blurRadius: 15,
          spreadRadius: 2,
        ),
      ],
    );
  }

  static LinearGradient meshGradient() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF1A0A26), // Deep Neon Purple
        Color(0xFF09090B),
        Color(0xFF051114), // Deep Cyan undertone
      ],
    );
  }

  static Widget glassOverlay({required Widget child, double blur = 15}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: child,
      ),
    );
  }
}
