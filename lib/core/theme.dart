import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color background = Color(0xFF070708);
  static const Color surface = Color(0xFF121214);
  static const Color primaryNeon = Color(0xFFD01CFF); 
  static const Color secondaryNeon = Color(0xFF00F0FF); 
  static const Color accentRed = Color(0xFFFF2D55);
  static const Color statGlow = Color(0xFF3BFFB1);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.transparent, // Allow for mesh background
      colorScheme: const ColorScheme.dark(
        primary: primaryNeon,
        secondary: secondaryNeon,
        surface: surface,
        error: accentRed,
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        const TextTheme(
          displayLarge: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: -1),
          displayMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
          titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
          bodyLarge: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500),
          bodyMedium: TextStyle(fontSize: 14, color: Colors.white70),
        ),
      ),
    );
  }

  static BoxDecoration glass({
    double blur = 10,
    double opacity = 0.1,
    BorderRadius? radius,
    Color? color,
  }) {
    return BoxDecoration(
      color: (color ?? Colors.white).withOpacity(opacity),
      borderRadius: radius ?? BorderRadius.circular(16),
      border: Border.all(
        color: Colors.white.withOpacity(0.1),
        width: 1,
      ),
    );
  }

  static LinearGradient meshGradient() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF0F0F12),
        Color(0xFF070708),
        Color(0xFF0A0214),
      ],
      stops: [0.0, 0.5, 1.0],
    );
  }

  static Widget glassOverlay({required Widget child, double blur = 12}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: child,
      ),
    );
  }
}
