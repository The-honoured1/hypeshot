import 'package:flutter/material.dart';
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
    // Modern Calm style: Soft solid fills or ghost borders
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: isPrimary ? Colors.white : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12), // Slightly less rounded for a tech-clean look
          border: isPrimary 
              ? null 
              : Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: isPrimary ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon, 
                color: isPrimary ? AppTheme.background : Colors.white, 
                size: 18,
              ),
              const SizedBox(width: 10),
            ],
            Text(
              label,
              style: TextStyle(
                color: isPrimary ? AppTheme.background : Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? glowColor;
  final BorderRadius? radius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.glowColor,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return AppTheme.glassOverlay(
      child: Container(
        padding: padding ?? const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: radius ?? BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.05),
            width: 0.5,
          ),
        ),
        child: child,
      ),
    );
  }
}
