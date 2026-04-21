import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme.dart';

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  const AnimatedBackground({super.key, required this.child});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base gradient
        Container(
          decoration: const BoxDecoration(gradient: AppTheme.subtleGradient),
        ),
        // Animated glow orbs
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              painter: _GlowOrbPainter(_controller.value),
              size: Size.infinite,
            );
          },
        ),
        widget.child,
      ],
    );
  }
}

class _GlowOrbPainter extends CustomPainter {
  final double progress;
  _GlowOrbPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    // Violet orb — top right, drifts slowly
    final violetCenter = Offset(
      size.width * 0.8 + sin(progress * 2 * pi) * 30,
      size.height * 0.15 + cos(progress * 2 * pi) * 20,
    );
    canvas.drawCircle(
      violetCenter,
      120,
      Paint()
        ..color = AppTheme.accentPrimary.withOpacity(0.06)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80),
    );

    // Coral orb — bottom left, drifts opposite
    final coralCenter = Offset(
      size.width * 0.2 + cos(progress * 2 * pi) * 25,
      size.height * 0.75 + sin(progress * 2 * pi) * 30,
    );
    canvas.drawCircle(
      coralCenter,
      100,
      Paint()
        ..color = AppTheme.accentSecondary.withOpacity(0.04)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 70),
    );
  }

  @override
  bool shouldRepaint(_GlowOrbPainter oldDelegate) => true;
}
