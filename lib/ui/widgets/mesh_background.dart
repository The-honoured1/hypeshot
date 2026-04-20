import 'package:flutter/material.dart';
import '../../core/theme.dart';

class MeshBackground extends StatelessWidget {
  final Widget child;
  const MeshBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: AppTheme.meshGradient(),
          ),
        ),
        // Very subtle ambient light
        Positioned(
          top: -200,
          right: -200,
          child: _GlowSpot(color: Colors.white.withOpacity(0.03), size: 600),
        ),
        Positioned(
          bottom: -100,
          left: -100,
          child: _GlowSpot(color: AppTheme.accent.withOpacity(0.05), size: 500),
        ),
        child,
      ],
    );
  }
}

class _GlowSpot extends StatelessWidget {
  final Color color;
  final double size;
  const _GlowSpot({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, Colors.transparent],
        ),
      ),
    );
  }
}
