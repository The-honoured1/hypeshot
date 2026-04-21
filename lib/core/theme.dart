import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Studio Pro Palette (Matte/Industrial) ──
  static const Color bgInk = Color(0xFF080808);      // Deep deepest matte
  static const Color bgSlate = Color(0xFF141416);    // Slate grey matte surface
  static const Color bgElevated = Color(0xFF1C1C1E); // Slightly elevated UI
  
  static const Color accentSignal = Color(0xFFFF3B30); // REC Red
  static const Color accentAmber = Color(0xFFFFA500);  // Standby Amber
  static const Color actionWhite = Color(0xFFFFFFFF);  // Pure White action
  
  static const Color textMain = Color(0xFFF5F5F7);
  static const Color textDim = Color(0xFF6E6E73);
  static const Color borderThin = Color(0xFF2C2C2E);

  // Legacy aliases for backward compatibility during transition
  static const Color background = bgInk;
  static const Color surface = bgSlate;
  static const Color accent = actionWhite;
  static const Color textPrimary = textMain;
  static const Color textSecondary = textDim;

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgInk,
      colorScheme: const ColorScheme.dark(
        primary: actionWhite,
        secondary: accentAmber,
        tertiary: accentSignal,
        surface: bgSlate,
        onSurface: textMain,
      ),
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: textMain,
            letterSpacing: -1,
          ),
          displayMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: textMain,
            letterSpacing: -0.5,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textMain,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: textMain,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textDim,
          ),
          labelSmall: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: textDim,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  // ── Studio Decoration Helpers ──
  static BoxDecoration studioCard({BorderRadius? radius, Color? color}) {
    return BoxDecoration(
      color: color ?? bgSlate,
      borderRadius: radius ?? BorderRadius.circular(4), // Sharp "Pro" corners
      border: Border.all(
        color: borderThin,
        width: 1,
      ),
    );
  }

  // Minimal glass kept but simplified to matte
  static BoxDecoration glass({BorderRadius? radius}) => studioCard(radius: radius);
  
  static LinearGradient brandGradient = const LinearGradient(colors: [bgInk, bgInk]); // Disabled gradients
  static LinearGradient meshGradient() => const LinearGradient(colors: [bgInk, bgInk]);

  static Widget studioOverlay({required Widget child}) {
    return Container(
      color: bgSlate,
      child: child,
    );
  }
  
  // Legacy cleanup
  static Widget glassOverlay({required Widget child, double blur = 40}) => studioOverlay(child: child);
}
