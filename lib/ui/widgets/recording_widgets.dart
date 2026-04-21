import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';

class HypeMeter extends StatelessWidget {
  final double level; // 0.0 to 1.0
  const HypeMeter({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'CAPTURE FOCUS',
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1),
            ),
            Text(
              '${(level * 100).toInt()}%',
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.accent),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 2,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            AnimatedContainer(
              duration: 1.seconds,
              height: 2,
              width: MediaQuery.of(context).size.width * level * 0.8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(1),
                color: AppTheme.accent,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class RecordingWave extends StatelessWidget {
  const RecordingWave({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 16,
      width: 32,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(4, (index) {
          return Container(
            width: 2,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(1),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true))
           .scaleY(
             begin: 0.4, 
             end: 1.0, 
             duration: Duration(milliseconds: 500 + (index * 150)),
             curve: Curves.easeInOut,
           );
        }),
      ),
    );
  }
}
