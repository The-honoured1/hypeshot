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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: isPrimary ? BoxDecoration(
          color: AppTheme.accent,
          borderRadius: BorderRadius.circular(24), // Smooth rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15), // Neomorphic drop
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ) : AppTheme.glass(radius: BorderRadius.circular(24)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
               Icon(
                icon, 
                color: isPrimary ? AppTheme.background : AppTheme.textPrimary, 
                size: 18,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                color: isPrimary ? AppTheme.background : AppTheme.textPrimary,
                fontWeight: FontWeight.w600, // Smooth weight
                fontSize: 14,
                letterSpacing: 0.5,
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
  final BorderRadius? radius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return AppTheme.glassOverlay(
      child: Container(
        padding: padding ?? const EdgeInsets.all(20),
        decoration: AppTheme.glass(radius: radius),
        child: child,
      ),
    );
  }
}
