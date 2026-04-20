import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color background = Color(0xFF0F1115); // Deep Slate
  static const Color surface = Color(0xFF1A1D23);    // Soft Charcoal
  static const Color accent = Color(0xFF7D8FA9);     // Muted Slate Blue
  static const Color textPrimary = Color(0xFFF0F0F2);
  static const Color textSecondary = Color(0xFF949BA5);
  static const Color alert = Color(0xFFBF616A);      // Calm Red

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
      textTheme: GoogleFonts.interTextTheme( // Switching to Inter for a more stable/calm feel
        const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32, 
            fontWeight: FontWeight.w700, 
            color: textPrimary,
            letterSpacing: -0.5,
          ),
          displayMedium: TextStyle(
            fontSize: 24, 
            fontWeight: FontWeight.w600, 
            color: textPrimary,
          ),
          titleMedium: TextStyle(
            fontSize: 16, 
            fontWeight: FontWeight.w600, 
            color: textPrimary, 
            letterSpacing: 0.5,
          ),
          bodyLarge: TextStyle(
            fontSize: 16, 
            color: textPrimary, 
            height: 1.5,
          ),
          bodyMedium: TextStyle(
            fontSize: 14, 
            color: textSecondary, 
            height: 1.4,
          ),
        ),
      ),
    );
  }

  static BoxDecoration glass({
    double blur = 20, // Increased for calm feel
    double opacity = 0.05, // Lowered for subtle frost
    BorderRadius? radius,
    Color? color,
  }) {
    return BoxDecoration(
      color: (color ?? Colors.white).withOpacity(opacity),
      borderRadius: radius ?? BorderRadius.circular(20),
      border: Border.all(
        color: Colors.white.withOpacity(0.05), // Very subtle border
        width: 0.5,
      ),
    );
  }

  static LinearGradient meshGradient() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF14171C),
        Color(0xFF0F1115),
        Color(0xFF121418),
      ],
    );
  }

  static Widget glassOverlay({required Widget child, double blur = 25}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: child,
      ),
    );
  }
}
