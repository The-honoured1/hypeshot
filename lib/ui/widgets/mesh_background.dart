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
        // Glow spots removed for full abstract dark aesthetic
        child,
      ],
    );
  }
}

