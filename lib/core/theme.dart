import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color background = Color(0xFF0B0F19); // Mist Slate
  static const Color surface = Color(0xFF151A28);    // Mist Surface
  static const Color accent = Color(0xFF8AB4F8);     // Muted Blue Accent
  static const Color textPrimary = Color(0xFFF1F3F4);
  static const Color textSecondary = Color(0xFF9AA0A6);
  static const Color alert = Color(0xFFF28B82);      // Muted Red

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: accent,
        surface: surface,
        onSurface: textPrimary,
        error: alert,
      ),
      textTheme: GoogleFonts.interTextTheme( // Clean, legible sans-serif
        const TextTheme(
          displayLarge: TextStyle(
            fontSize: 28, 
            fontWeight: FontWeight.w600, 
            color: textPrimary,
            letterSpacing: -0.5,
          ),
          displayMedium: TextStyle(
            fontSize: 22, 
            fontWeight: FontWeight.w600, 
            color: textPrimary,
          ),
          titleMedium: TextStyle(
            fontSize: 16, 
            fontWeight: FontWeight.w500, 
            color: textPrimary, 
          ),
          bodyLarge: TextStyle(
            fontSize: 16, 
            fontWeight: FontWeight.w400,
            color: textPrimary, 
            height: 1.5,
          ),
          bodyMedium: TextStyle(
            fontSize: 14, 
            fontWeight: FontWeight.w400,
            color: textSecondary, 
            height: 1.4,
          ),
        ),
      ),
    );
  }

  static BoxDecoration glass({
    double blur = 30, // Deep frost
    double opacity = 0.03, // Ultra-subtle
    BorderRadius? radius,
    Color? color,
  }) {
    return BoxDecoration(
      color: (color ?? Colors.white).withOpacity(opacity),
      borderRadius: radius ?? BorderRadius.circular(16), // Softer pill corners
      border: Border.all(
        color: Colors.white.withOpacity(0.05), // Ultra-thin hair border
        width: 0.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2), // Neomorphic drop down shadow
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  static LinearGradient meshGradient() {
    // Replaced with a completely subtle mist gradient
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF0B0F19), // Mist Slate
        Color(0xFF05070C), // Darker slate
      ],
    );
  }

  static Widget glassOverlay({required Widget child, double blur = 30}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: child,
      ),
    );
  }
}
