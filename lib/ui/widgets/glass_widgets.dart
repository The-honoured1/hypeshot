import 'package:flutter/material.dart';
import '../../core/theme.dart';

class HypeButton extends StatefulWidget {
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
  State<HypeButton> createState() => _HypeButtonState();
}

class _HypeButtonState extends State<HypeButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: widget.isPrimary
              ? BoxDecoration(
                  gradient: AppTheme.brandGradient,
                  borderRadius: BorderRadius.circular(14),
                )
              : AppTheme.surfaceCard(radius: BorderRadius.circular(14)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  color: widget.isPrimary
                      ? Colors.white
                      : AppTheme.textPrimary,
                  size: 18,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.isPrimary
                      ? Colors.white
                      : AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
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
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: AppTheme.surfaceCard(radius: radius),
      child: child,
    );
  }
}
