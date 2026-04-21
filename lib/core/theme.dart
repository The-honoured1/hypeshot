import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Neon Surge Palette ──
  static const Color bgDeep = Color(0xFF0D0D12);
  static const Color bgCard = Color(0xFF16161E);
  static const Color bgElevated = Color(0xFF1E1E2A);
  
  static const Color accentPrimary = Color(0xFF8B5CF6);   // Electric Violet
  static const Color accentSecondary = Color(0xFFF43F5E); // Hot Coral
  static const Color accentTertiary = Color(0xFF06B6D4);  // Cyan
  
  static const Color textPrimary = Color(0xFFF0F0F5);
  static const Color textSecondary = Color(0xFF6B6B80);
  static const Color textMuted = Color(0xFF3A3A4A);

  // Legacy aliases for files that still reference old names
  static const Color background = bgDeep;
  static const Color surface = bgCard;
  static const Color accent = accentPrimary;

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDeep,
      colorScheme: const ColorScheme.dark(
        primary: accentPrimary,
        secondary: accentSecondary,
        tertiary: accentTertiary,
        surface: bgCard,
        onSurface: textPrimary,
      ),
      textTheme: GoogleFonts.spaceGroteskTextTheme(
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
            letterSpacing: -0.3,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
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
          labelSmall: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: textSecondary,
            letterSpacing: 1.2,
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: bgElevated,
        selectedItemColor: accentPrimary,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 0,
      ),
    );
  }

  // ── Gradients ──
  static const LinearGradient brandGradient = LinearGradient(
    colors: [accentPrimary, accentSecondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient subtleGradient = LinearGradient(
    colors: [Color(0xFF1A1A2E), Color(0xFF0D0D12)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ── Surface Card Decoration ──
  static BoxDecoration surfaceCard({BorderRadius? radius}) {
    return BoxDecoration(
      color: bgCard,
      borderRadius: radius ?? BorderRadius.circular(16),
      border: Border.all(
        color: Colors.white.withOpacity(0.06),
        width: 1,
      ),
    );
  }

  // ── Accent Glass Decoration ──
  static BoxDecoration accentGlass({
    BorderRadius? radius,
    Color? color,
    double opacity = 0.08,
  }) {
    return BoxDecoration(
      color: (color ?? accentPrimary).withOpacity(opacity),
      borderRadius: radius ?? BorderRadius.circular(16),
      border: Border.all(
        color: (color ?? accentPrimary).withOpacity(0.2),
        width: 1,
      ),
    );
  }

  // Legacy glass method kept for backward compat
  static BoxDecoration glass({
    double blur = 40,
    double opacity = 0.02,
    BorderRadius? radius,
    Color? color,
  }) {
    return surfaceCard(radius: radius);
  }

  static LinearGradient meshGradient() => subtleGradient;

  static Widget glassOverlay({required Widget child, double blur = 40}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: child,
      ),
    );
  }
}
