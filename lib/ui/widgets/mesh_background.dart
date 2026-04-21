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
        // Dynamic aggressive neon light
        Positioned(
          top: -150,
          right: -150,
          child: _GlowSpot(color: AppTheme.alert.withOpacity(0.15), size: 400),
        ),
        Positioned(
          bottom: -100,
          left: -100,
          child: _GlowSpot(color: AppTheme.accent.withOpacity(0.12), size: 500),
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
