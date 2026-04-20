import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';

class HypeButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;
  final IconData? icon;

  const HypeButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isPrimary = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final color = isPrimary ? AppTheme.primaryNeon : AppTheme.secondaryNeon;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.7)],
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 12),
            ],
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true))
     .scale(begin: const Offset(1, 1), end: const Offset(1.02, 1.02), duration: 2.seconds);
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? glowColor;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppTheme.glassOverlay(
      child: Container(
        padding: padding ?? const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: (glowColor ?? Colors.white).withOpacity(0.1),
            width: 1,
          ),
        ),
        child: child,
      ),
    );
  }
}
