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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: widget.isPrimary 
              ? (_pressed ? AppTheme.textMain.withOpacity(0.8) : AppTheme.actionWhite)
              : Colors.transparent,
          border: Border.all(
            color: widget.isPrimary ? Colors.transparent : AppTheme.borderThin,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) ...[
              Icon(
                widget.icon,
                color: widget.isPrimary ? Colors.black : AppTheme.textMain,
                size: 16,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              widget.label.toUpperCase(),
              style: TextStyle(
                color: widget.isPrimary ? Colors.black : AppTheme.textMain,
                fontWeight: FontWeight.w900,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StudioCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final BorderRadius? radius;

  const StudioCard({
    super.key,
    required this.child,
    this.padding,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: AppTheme.studioCard(radius: radius),
      child: child,
    );
  }
}
