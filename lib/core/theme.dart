import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color background = Color(0xFF0A0A0C); // Deep Obsidian
  static const Color surface = Color(0xFF121216);    // Flat Charcoal
  static const Color accent = Color(0xFFE2E8F0);     // Glacial White
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF71717A); // Zinc 500
  static const Color alert = Color(0xFF3F3F46);      // Muted Zinc instead of red/alert

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
      textTheme: GoogleFonts.interTextTheme( // Keep clean font
        const TextTheme(
          displayLarge: TextStyle(
            fontSize: 28, 
            fontWeight: FontWeight.w600, 
            color: textPrimary,
            letterSpacing: 0.5, // Increased spacing for abstract feel
          ),
          displayMedium: TextStyle(
            fontSize: 22, 
            fontWeight: FontWeight.w500, 
            color: textPrimary,
            letterSpacing: 0.5,
          ),
          titleMedium: TextStyle(
            fontSize: 16, 
            fontWeight: FontWeight.w500, 
            color: textPrimary, 
            letterSpacing: 0.5,
          ),
          bodyLarge: TextStyle(
            fontSize: 16, 
            fontWeight: FontWeight.w400,
            color: textPrimary, 
            height: 1.6,
            letterSpacing: 0.2,
          ),
          bodyMedium: TextStyle(
            fontSize: 14, 
            fontWeight: FontWeight.w400,
            color: textSecondary, 
            height: 1.5,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  static BoxDecoration glass({
    double blur = 40, // More frosted blur
    double opacity = 0.02, // Sheer
    BorderRadius? radius,
    Color? color,
  }) {
    return BoxDecoration(
      color: (color ?? Colors.white).withOpacity(opacity),
      borderRadius: radius ?? BorderRadius.circular(12), // Tighter pill corners
      border: Border.all(
        color: Colors.white.withOpacity(0.04), // Barely visible hairline limit
        width: 1.0,
      ),
      // Neomorphism removed completely
    );
  }

  static LinearGradient meshGradient() {
    // Monochromatic deep space gradient
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF0A0A0C), 
        Color(0xFF0E0E12),
        Color(0xFF050507),
      ],
    );
  }

  static Widget glassOverlay({required Widget child, double blur = 40}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: child,
      ),
    );
  }
}
